
`timescale 1 ns / 1 ps

/**
 * @note:
 * 1. size of image must be integral multiple of C_M_AXI_DATA_WIDTH * C_M_AXI_BURST_LEN.
 * 2. the sof [start of frame] must be 1'b1 for first image data.
 */
module PVDMA_M_AXI_W #
(
	// Users to add parameters here

	// User parameters ends
	// Do not modify the parameters beyond this line

	// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
	parameter integer C_M_AXI_BURST_LEN	= 16,
	// Thread ID Width
	parameter integer C_M_AXI_ID_WIDTH	= 1,
	// Width of Address Bus
	parameter integer C_M_AXI_ADDR_WIDTH	= 32,
	// Width of Data Bus
	parameter integer C_M_AXI_DATA_WIDTH	= 32
)
(
	// Users to add ports here
	input wire sof,
	input wire [C_M_AXI_DATA_WIDTH-1 : 0] din,
	input wire empty,
	output wire rd_en,

	output reg frame_pulse,
	input wire [C_M_AXI_ADDR_WIDTH-1 : 0] base_addr,

	// User ports ends
	// Do not modify the ports beyond this line

	// Global Clock Signal.
	input wire  M_AXI_ACLK,
	// Global Reset Singal. This Signal is Active Low
	input wire  M_AXI_ARESETN,
	// Master Interface Write Address ID
	output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID,
	// Master Interface Write Address
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
	// Burst length. The burst length gives the exact number of transfers in a burst
	output wire [7 : 0] M_AXI_AWLEN,
	// Burst size. This signal indicates the size of each transfer in the burst
	output wire [2 : 0] M_AXI_AWSIZE,
	// Burst type. The burst type and the size information,
// determine how the address for each transfer within the burst is calculated.
	output wire [1 : 0] M_AXI_AWBURST,
	// Lock type. Provides additional information about the
// atomic characteristics of the transfer.
	output wire M_AXI_AWLOCK,
	// Memory type. This signal indicates how transactions
// are required to progress through a system.
	output wire [3 : 0] M_AXI_AWCACHE,
	// Protection type. This signal indicates the privilege
// and security level of the transaction, and whether
// the transaction is a data access or an instruction access.
	output wire [2 : 0] M_AXI_AWPROT,
	// Quality of Service, QoS identifier sent for each write transaction.
	output wire [3 : 0] M_AXI_AWQOS,
	// Write address valid. This signal indicates that
// the channel is signaling valid write address and control information.
	output wire M_AXI_AWVALID,
	// Write address ready. This signal indicates that
// the slave is ready to accept an address and associated control signals
	input wire  M_AXI_AWREADY,
	// Master Interface Write Data.
	output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
	// Write strobes. This signal indicates which byte
// lanes hold valid data. There is one write strobe
// bit for each eight bits of the write data bus.
	output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
	// Write last. This signal indicates the last transfer in a write burst.
	output wire M_AXI_WLAST,
	// Write valid. This signal indicates that valid write
// data and strobes are available
	output wire M_AXI_WVALID,
	// Write ready. This signal indicates that the slave
// can accept the write data.
	input wire  M_AXI_WREADY,
	// Master Interface Write Response.
	input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID,
	// Write response. This signal indicates the status of the write transaction.
	input wire [1 : 0] M_AXI_BRESP,
	// Write response valid. This signal indicates that the
// channel is signaling a valid write response.
	input wire  M_AXI_BVALID,
	// Response ready. This signal indicates that the master
// can accept a write response.
	output wire  M_AXI_BREADY
);


	// function called clogb2 that returns an integer which has the
	//value of the ceiling of the log base 2

	// function called clogb2 that returns an integer which has the
	// value of the ceiling of the log base 2.
	function integer clogb2 (input integer bit_depth);
	begin
		for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
			bit_depth = bit_depth >> 1;
		end
	endfunction

	// C_TRANSACTIONS_NUM is the width of the index counter for
	// number of write or read transaction.
	localparam integer C_TRANSACTIONS_NUM	= clogb2(C_M_AXI_BURST_LEN-1);
	//Burst size in bytes
	localparam integer C_BURST_SIZE_BYTES	= C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;

	// @note: do not cause bursts across 4K address boundaries.

	reg r_sof;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] r_din;
	reg r_dvalid;

	//AXI4 internal temp signals
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awvalid;
	reg  	axi_wlast;
	wire  	axi_wvalid;
	reg  	axi_bready;
	//write beat count in a burst
	reg [C_TRANSACTIONS_NUM : 0] 	write_index;
	reg  	start_single_burst_write;
	reg  	burst_write_active;
	//Interface response error flags
	wire  	write_resp_error;
	wire  	wnext;


	// I/O Connections assignments
	assign rd_en		= ~empty && (~r_dvalid | wnext);
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			r_dvalid <= 1'b0;
		else
			r_dvalid <= rd_en;
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			r_din <= 'b0;
		else if (rd_en)
			r_din <= din;
		else
			r_din <= r_din;
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			r_sof <= 'b0;
		else if (rd_en)
			r_sof <= sof;
		else
			r_sof <= r_sof;
	end

	//I/O Connections. Write Address (AW)
	assign M_AXI_AWID	= 'b0;
	//The AXI address is a concatenation of the target base address + active offset range
	assign M_AXI_AWADDR	= axi_awaddr;
	//Burst LENgth is number of transaction beats, minus 1
	assign M_AXI_AWLEN	= C_M_AXI_BURST_LEN - 1;
	//Size should be C_M_AXI_DATA_WIDTH, in 2^SIZE bytes, otherwise narrow bursts are used
	assign M_AXI_AWSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	//INCR burst type is usually used, except for keyhole bursts
	assign M_AXI_AWBURST	= 2'b01;
	assign M_AXI_AWLOCK	= 1'b0;
	//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
	assign M_AXI_AWCACHE	= 4'b0010;
	assign M_AXI_AWPROT	= 3'h0;
	assign M_AXI_AWQOS	= 4'h0;
	assign M_AXI_AWVALID	= axi_awvalid;
	//Write Data(W)
	assign M_AXI_WDATA	= r_din;
	//All bursts are complete and aligned in this example
	assign M_AXI_WSTRB	= {(C_M_AXI_DATA_WIDTH/8){1'b1}};
	assign M_AXI_WLAST	= axi_wlast;
	assign M_AXI_WVALID	= axi_wvalid;
	//Write Response (B)
	assign M_AXI_BREADY	= axi_bready;

	//--------------------
	//Write Address Channel
	//--------------------

	// The purpose of the write address channel is to request the address and
	// command information for the entire transaction.  It is a single beat
	// of information.

	// The AXI4 Write address channel in this example will continue to initiate
	// write commands as fast as it is allowed by the slave/interconnect.
	// The address will be incremented on each accepted address transaction,
	// by burst_size_byte to point to the next address.

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			axi_awvalid <= 1'b0;
		// If previously not valid , start next transaction
		else if (~axi_awvalid && start_single_burst_write)
			axi_awvalid <= 1'b1;
		/* Once asserted, VALIDs cannot be deasserted, so axi_awvalid
		must wait until transaction is accepted */
		else if (M_AXI_AWREADY && axi_awvalid)
			axi_awvalid <= 1'b0;
		else
			axi_awvalid <= axi_awvalid;
	end


	// Next address after AWREADY indicates previous address acceptance
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			axi_awaddr <= 'b0;
		else if (start_single_burst_write) begin
			if (r_sof)
				axi_awaddr <= base_addr;
			else
				axi_awaddr <= axi_awaddr;
		end
		else if (M_AXI_AWREADY && axi_awvalid)
			axi_awaddr <= axi_awaddr + C_BURST_SIZE_BYTES;
		else
			axi_awaddr <= axi_awaddr;
	end


	//--------------------
	//Write Data Channel
	//--------------------

	//The write data will continually try to push write data across the interface.

	//The amount of data accepted will depend on the AXI slave and the AXI
	//Interconnect settings, such as if there are FIFOs enabled in interconnect.

	//Note that there is no explicit timing relationship to the write address channel.
	//The write channel has its own throttling flag, separate from the AW channel.

	//Synchronization between the channels must be determined by the user.

	//The simpliest but lowest performance would be to only issue one address write
	//and write data burst at a time.

	//In this example they are kept in sync by using the same address increment
	//and burst sizes. Then the AW and W channels have their transactions measured
	//with threshold counters as part of the user logic, to make sure neither
	//channel gets too far ahead of each other.

	//Forward movement occurs when the write channel is valid and ready

	assign wnext = M_AXI_WREADY & axi_wvalid;

	// WVALID logic, similar to the axi_awvalid always block above
	reg r_wvalid_keep;
	assign axi_wvalid = r_wvalid_keep & r_dvalid;
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			r_wvalid_keep <= 1'b0;
		// If previously not valid, start next transaction
		else if (~r_wvalid_keep && start_single_burst_write)
			r_wvalid_keep <= 1'b1;
		/* If WREADY and too many writes, throttle WVALID
		Once asserted, VALIDs cannot be deasserted, so WVALID
		must wait until burst is complete with WLAST */
		else if (wnext && axi_wlast)
			r_wvalid_keep <= 1'b0;
		else
			r_wvalid_keep <= r_wvalid_keep;
	end


	//WLAST generation on the MSB of a counter underflow
	// WVALID logic, similar to the axi_awvalid always block above
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			axi_wlast <= 1'b0;
		// axi_wlast is asserted when the write index
		// count reaches the penultimate count to synchronize
		// with the last write data when write_index is b1111
		// else if (&(write_index[C_TRANSACTIONS_NUM-1:1])&& ~write_index[0] && wnext)
		else if ((write_index == 1 && wnext) || C_M_AXI_BURST_LEN == 1)
			axi_wlast <= 1'b1;
		// Deassrt axi_wlast when the last write data has been
		// accepted by the slave with a valid response
		else if (wnext)
			axi_wlast <= 1'b0;
		else
			axi_wlast <= axi_wlast;
	end


	/* Burst length counter. Uses extra counter register bit to indicate terminal
	 count to reduce decode logic */
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0 || start_single_burst_write == 1'b1)
			write_index <= C_M_AXI_BURST_LEN-1;
		else if (wnext && (write_index != 0))
			write_index <= write_index - 1;
		else
			write_index <= write_index;
	end

	//----------------------------
	//Write Response (B) Channel
	//----------------------------

	//The write response channel provides feedback that the write has committed
	//to memory. BREADY will occur when all of the data and the write address
	//has arrived and been accepted by the slave.

	//The write issuance (number of outstanding write addresses) is started by
	//the Address Write transfer, and is completed by a BREADY/BRESP.

	//While negating BREADY will eventually throttle the AWREADY signal,
	//it is best not to throttle the whole data channel this way.

	//The BRESP bit [1] is used indicate any errors from the interconnect or
	//slave for the entire write burst. This example will capture the error
	//into the ERROR output.

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			axi_bready <= 1'b0;
		// accept/acknowledge bresp with axi_bready by the master
		// when M_AXI_BVALID is asserted by slave
		else if (M_AXI_BVALID && ~axi_bready)
			axi_bready <= 1'b1;
		// deassert after one clock cycle
		else if (axi_bready)
			axi_bready <= 1'b0;
		// retain the previous value
		else
			axi_bready <= axi_bready;
	end


	//Flag any write response errors
	assign write_resp_error = axi_bready & M_AXI_BVALID & M_AXI_BRESP[1];


	//--------------------------------
	//Example design throttling
	//--------------------------------

	// For maximum port throughput, this user example code will try to allow
	// each channel to run as independently and as quickly as possible.

	// However, there are times when the flow of data needs to be throtted by
	// the user application. This example application requires that data is
	// not read before it is written and that the write channels do not
	// advance beyond an arbitrary threshold (say to prevent an
	// overrun of the current read address by the write address).

	// From AXI4 Specification, 13.13.1: "If a master requires ordering between
	// read and write transactions, it must ensure that a response is received
	// for the previous transaction before issuing the next transaction."

	// This example accomplishes this user application throttling through:
	// -Reads wait for writes to fully complete
	// -Address writes wait when not read + issued transaction counts pass
	// a parameterized threshold
	// -Writes wait when a not read + active data burst count pass
	// a parameterized threshold


	//implement master command interface state machine

	always @ ( posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0 ) begin
			// reset condition
			// All the signals are assigned default values under reset condition
			frame_pulse <= 1'b0;
		end
		else begin
			// This state is responsible to issue start_single_write pulse to
			// initiate a write transaction. Write transactions will be
			// issued until burst_write_active signal is asserted.
			// write controller
			// @note: start a burst when receiving a single valid data at least
			if (~axi_awvalid && ~frame_pulse && ~burst_write_active && r_dvalid)
				frame_pulse <= 1'b1;
			else
				frame_pulse <= 1'b0; //Negate to generate a pulse
		end
	end //MASTER_EXECUTION_PROC

	/// @note: delay one clock cycle to wait base_addr!
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0)
			start_single_burst_write <= 1'b0;
		else
			start_single_burst_write <= frame_pulse;
	end


	  // burst_write_active signal is asserted when there is a burst write transaction
	  // is initiated by the assertion of start_single_burst_write. burst_write_active
	  // signal remains asserted until the burst write is accepted by the slave
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			burst_write_active <= 1'b0;
		//The burst_write_active is asserted when a write burst transaction is initiated
		else if (start_single_burst_write)
			burst_write_active <= 1'b1;
		else if (M_AXI_BVALID && axi_bready)
			burst_write_active <= 0;
	end

	// Add user logic here

	// User logic ends

endmodule
