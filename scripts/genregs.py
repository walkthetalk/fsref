#!/usr/bin/env python
import sys
import inspect
import pathlib
from sympy.parsing.sympy_parser import parse_expr

def get_scirpt_dir():
	filename = inspect.getframeinfo(inspect.currentframe()).filename
	parent = pathlib.Path(filename).resolve().parent
	return parent

def getMaxLen(dictlist, memname):
	return len(max(dictlist, key=lambda p: len(p[memname]))[memname])

def lenof(dictlist, memname):
	return max(dictlist, key=lambda p: p.lenof(memname)).lenof(memname)
def prefixtab(lvl):
	return "{:\t<{}}".format("", str(lvl))
def suppline(lvl, s):
	return prefixtab(lvl) + s + "\n"
def suppcomment(lvl, s):
	return prefixtab(lvl) + "/// " + s + "\n"
def suppsection(lvl, s):
	clen = 80 - lvl * 8
	h = prefixtab(lvl)
	ret = ''
	ret += h + '/*{:*<{}}\n'.format('',str(clen - 3))
	sstr = ' section: ' + s + ' '
	ret += h + ' *{: ^{}}*\n'.format(sstr, str(clen - 4))
	ret += h + ' *{:*<{}}*/\n'.format('',str(clen - 4))
	return ret
def suppreadreg0(lvl, ridx):
	return suppline(lvl, "assign slv_reg[{}] = 0;".format(str(ridx)))

def str4array(ifname='', pname='', namelen = 0):
	ifprefix = '' if ifname == '' else (ifname + '_')
	return "{}{:<{}}".format(ifprefix, pname, namelen)
def str4cfg(ifname='', pname='', namelen = 0):
	ifprefix = '' if ifname == '' else (ifname + '_')
	return "r_{}{:<{}}".format(ifprefix, pname, namelen)
def str4intena(ifname='', pname='', namelen = 0):
	ifprefix = '' if ifname == '' else (ifname + '_')
	return "int_ena_{}{:<{}}".format(ifprefix, pname, namelen)
def str4intsta(ifname='', pname='', namelen = 0):
	ifprefix = '' if ifname == '' else (ifname + '_')
	return "int_sta_{}{:<{}}".format(ifprefix, pname, namelen)
def str4intdly(ifname='', pname='', namelen = 0):
	ifprefix = '' if ifname == '' else (ifname + '_')
	return "int_dly_{}{:<{}}".format(ifprefix, pname, namelen)
def str4intclr(ifname='', pname='', namelen = 0):
	ifprefix = '' if ifname == '' else (ifname + '_')
	return "int_clr_{}{:<{}}".format(ifprefix, pname, namelen)
def str4regdef(ridx):
	return 'reg{}define'.format(str(ridx))
def str4regdefcomment(ridx):
	return 'reg {} - {:=09_b}'.format(str(ridx), ridx)
def str4loopheader(start, end, name, varname='i'):
	return "for ({0} = {1}; {0} < {2}; {0}={0}+1) begin: {3}".format(varname, str(start), str(end), name)
def str4looptail():
	return 'end'
def str4alwaysbegin():
	return 'always @ (posedge o_clk) begin'
def str4alwaysend():
	return 'end'

def h2lrange(l, w):
	lstr = str(l)
	wstr = str(w)
	if wstr == '1' or wstr == '':
		return '[{}]'.format(lstr)
	hstr = parse_expr('{}+{}-1'.format(wstr, lstr))
	return '[{}:{}]'.format(hstr, lstr)
def drc_defreg(lvl, width, name, wrtype):
	if str(width) == '1' or str(width) == '':
		return suppline(lvl, '{} {};'.format(wrtype, name))
	try:
		hidx = str(int(width-1))
	except:
		hidx = width + '-1'
	return suppline(lvl, '{} {} {};'.format(wrtype, h2lrange(0, width), name))
def drc_trig(lvl, name, dep, defv = 0, autoclr='false'):
	ret = ''
	defstr = str(defv)
	invstr = '1' if defstr == '0' else '0'
	ret += suppline(lvl, str4alwaysbegin())
	ret += suppline(lvl+1, 'if (o_resetn == 1\'b0)')
	ret += suppline(lvl+2, "{} <= {};".format(name, defstr))
	ret += suppline(lvl+1, 'else if ({})'.format(str(dep)))
	ret += suppline(lvl+2, '{} <= {};'.format(name, invstr))
	if autoclr == 'true':
		ret += suppline(lvl+1, 'else')
		ret += suppline(lvl+2, '{} <= {};'.format(name, defstr))
	ret += suppline(lvl, str4alwaysend())
	return ret
def drc_WL(lvl, ridx, lbit, width, name, defv, autoclr='false', dep=''):
	ret = ''
	ret += suppline(lvl, str4alwaysbegin())
	ret += suppline(lvl+1, 'if (o_resetn == 1\'b0)')
	ret += suppline(lvl+2, "{} <= {};".format(name, str(defv)))
	depstr = '' if (dep == '') else (' && ' + dep)
	ret += suppline(lvl+1, 'else if (wre_sync[{}]{})'.format(str(ridx), depstr))
	ret += suppline(lvl+2, '{} <= wrd_sync{};'.format(name, h2lrange(lbit, width)))
	if autoclr == 'true':
		ret += suppline(lvl+1, 'else')
		ret += suppline(lvl+2, '{} <= 0;'.format(name))
	ret += suppline(lvl, str4alwaysend())
	return ret
def drc_RL(lvl, ridx, lbit, width, name):
	wstr = str(width)
	return suppline(lvl, 'assign slv_reg[{}]{} = {};'.format(str(ridx), h2lrange(lbit, width), name))

def drc_RW(lvl, ridx, lbit, width, name, defv=0, autoclr='false', dep=''):
	ret = ''
	ret += drc_WL(lvl, ridx, lbit, width, name, defv, autoclr, dep)
	ret += drc_RL(lvl, ridx, lbit, width, name)
	return ret

def drc_int_ena(lvl, ridx, lbit, name):
	return drc_RW(lvl, ridx, lbit, 1, name, 0)
def drc_int_sta(lvl, ridx, lbit, name):
	return drc_RL(lvl, ridx, lbit, 1, name)
def drc_int_clr(lvl, ridx, lbit, name):
	return suppline(lvl, 'assign {} = wre_sync[{}] && wrd_sync[{}];'.format(
			name, str(ridx), str(lbit)))
def drc_rw(lvl, ridx, lbit, width, name, defv=0, autoclr='false', dep=''):
	return drc_RW(lvl, ridx, lbit, width, name, defv, autoclr, dep)
def drc_wo(lvl, ridx, lbit, width, name, defv=0, autoclr='false', dep=''):
	return drc_WL(lvl, ridx, lbit, width, name, defv, autoclr, dep)
def drc_ro(lvl, ridx, lbit, width, name):
	return drc_RL(lvl, ridx, lbit, width, name)
def drc_ind(lvl, ridx, lbit, width, rwtype, name, dstlbit, loopsize, sel, defv=0, autoclr='false'):
	ret = ''
	dstpartfix = '' if dstlbit == '' else ('_' + str(dstlbit))
	if (rwtype == 'ro' or rwtype == 'rw'):
		wrapper = 'ind_' + name + dstpartfix
		ret += drc_defreg(lvl, width, wrapper, 'reg')
	dstpartrange = '' if dstlbit == '' else (h2lrange(dstlbit, width))
	dstnamei = name + '[i]' + dstpartrange
	dstnamej = name + '[j]' + dstpartrange


	if (rwtype == 'wo' or rwtype == 'rw'):
		ret += suppline(lvl, str4loopheader(0, loopsize, 'loop4write_' + wrapper))
		ret += drc_WL(lvl+1, ridx, lbit, width, dstnamei, defv, autoclr, sel + '[i]')
		ret += suppline(lvl, str4looptail())
	if (rwtype == 'ro' or rwtype == 'rw'):
		ret += suppcomment(lvl, 'load to ind reg continuously')
		ret += suppline(lvl, 'always @ (posedge o_clk) begin')
		ret += suppline(lvl+1, str4loopheader(0, loopsize, 'loop4read_' + wrapper, 'j'))
		ret += suppline(lvl+2, 'if ({})'.format(sel + '[j]'))
		ret += suppline(lvl+3, '{} <= {};'.format(wrapper, dstnamej))
		ret += suppline(lvl+1, str4looptail())
		ret += suppline(lvl, 'end')

	ret += drc_RL(lvl, ridx, lbit, width, wrapper)
	return ret

def fmtend(isext, islast):
	if isext:
		return "" if islast else ','
	return ';'
def ifidx2str(ifidx):
	return str(ifidx)

def stringfy2(widthprovider, hlwname, sizeprovider, hlsname, _nameprefix, _name, _iotype, _wrtype, lendict, isext, islast):
	finalstr = fmtend(isext, islast)

	sizestr  = sizeprovider._strRange((finalstr == ""), lendict, hlsname)
	finalstr = sizestr + finalstr

	namestr  = ' {}{:<{}}'.format(_nameprefix, _name, str(0) if (finalstr == "") else str(lendict["name"]))
	finalstr = namestr + finalstr

	widthstr = widthprovider._strRange((finalstr == ""), lendict, hlwname)
	finalstr = widthstr + finalstr

	wrtypestr = '{:<{}}'.format(_wrtype,
	str(0) if (finalstr == "") else str(lendict["wrtype"]))
	finalstr = wrtypestr + finalstr

	iotypestr = ""
	if isext:
		iotypestr = "{:<{}} ".format(_iotype, str(lendict["iotype"]))
	else:
		if ("iotype" in lendict):
			iotypestr = "/*{:<{}}*/ ".format(_iotype, str(lendict["iotype"]))
	finalstr = iotypestr + finalstr
	return finalstr

class VBase:
	def __init__(self, dictData):
		self._d = dictData
	@property
	def name(self):
		return self._getMem("name", "unkown")
	@property
	def comments(self):
		return self._getMem("comments", "")
	def lenof(self, memname):
		prop = getattr(self, memname)
		return len(prop)
	def serialize(self, lvl, lendict, isext, islast):
		ret = ""
		if self._has("comments"):
			ret += suppcomment(lvl, self.comments)
		return ret + suppline(lvl, self.stringfy(lendict, isext, islast))
	def stringfy(self, lendict, isext, islast):
		return ""
	def _has(self, memname):
		return (memname in self._d)
	def _get(self, memname):
		return self._d[memname]
	def _getMem(self, memname, defV):
		if self._has(memname):
			return self._get(memname)
		return defV
	def _strRange(self, canempty, lendict, hlsmem):
		hmem = hlsmem[0]
		lmem = hlsmem[1]
		smem = hlsmem[2]
		strLGRP = " [{0:<{1}}:{2:<{3}}]"
		lenhmem = lendict[hmem] if hmem in lendict else 0
		lenlmem = lendict[lmem] if lmem in lendict else 0
		tmp = lenhmem + lenlmem
		maxGrpLen = (0 if (tmp == 0) else tmp + len(strLGRP.format("", "0", "", "0")))
		if (self._has(hmem) or self._has(smem)):
			return strLGRP.format(
					eval("self." + hmem), str(lenhmem),
					eval("self." + lmem), str(lenlmem))
		else:
			if canempty:
				return ""
			return "{0:<{1}}".format("", str(maxGrpLen))

class VParam(VBase):
	def __init__(self, dictData):
		super(VParam, self).__init__(dictData)
	@property
	def dtype(self):
		return self._getMem("dtype", "integer")
	@property
	def defV(self):
		return self._getMem("defV", "0")
	def stringfy(self, lendict, isext, islast):
		return 'parameter {:<{}} {: <{}} = {: <{}}{}'.format(
			self.dtype, str(lendict["dtype"]),
			self.name,  str(lendict["name"]),
			self.defV,  (str(0) if islast else str(lendict["defV"])),
			fmtend(isext, islast))

class VLocalparam(VBase):
	def __init__(self, dictData):
		super(VLocalparam, self).__init__(dictData)
	@property
	def dtype(self):
		return self._getMem("dtype", "integer")
	@property
	def defV(self):
		return self._getMem("defV", "0")
	def stringfy(self, lendict, isext, islast):
		return 'localparam {:<{}} {: <{}} = {: <{}}{}'.format(
			self.dtype, str(lendict["dtype"]),
			self.name,  str(lendict["name"]),
			self.defV,  str(lendict["defV"]),
			fmtend(isext, islast))

class VPort(VBase):
	def __init__(self, dictData):
		super(VPort, self).__init__(dictData)
	@property
	def mirror(self):
		return self._getMem("mirror", "")
	@property
	def iotype(self):
		return self._getMem("iotype", "")
	@property
	def wrtype(self):
		return self._getMem("wrtype", "wire")
	# only for output port
	@property
	def defV(self):
		return self._getMem("defV", "0")
	# only for output port
	@property
	def fixedV(self):
		return self._getMem("fixedV", "")
	@property
	def lbit(self):
		if self._has("hbit"):
			return "0"
		if self._has("width"):
			return "0"
		return ""
	@property
	def hbit(self):
		if self._has("hbit"):
			return self._get("hbit")
		if self._has("width"):
			return self._get("width") + "-1"
		return ""
	@property
	def width(self):
		if self._has("hbit"):
			return self._get("hbit") + "+1"
		if self._has("width"):
			return self._get("width")
		return ""
	@property
	def lidx(self):
		if self._has("hidx"):
			return "0"
		if self._has("size"):
			return "0"
		return ""
	@property
	def hidx(self):
		if self._has("hidx"):
			return self._get("hidx")
		if self._has("size"):
			sstr = self._get("size")
			try:
				return str(int(sstr) - 1)
			except:
				return sstr + "-1"
		return ""
	@property
	def size(self):
		if self._has("hidx"):
			return self._get("hidx") + "+1"
		if self._has("size"):
			return self._get("size")
		return ""
	def stringfy(self, lendict, isext, islast):
		return stringfy2(
				self, ["hbit", "lbit", "width"],
				self, ["hidx", "lidx", "size"],
				"", self.name, self.iotype, self.wrtype, lendict, isext, islast)

class VIfProxy(VBase):
	def __init__(self, vif, serializefunc = "serialize", lenoffunc = "lenof"):
		super(VIfProxy, self).__init__([])
		self._vif = vif
		self._serializefunc = serializefunc
		self._lenoffunc = lenoffunc
	def serialize(self, lvl, lendict, isext, islast):
		return eval("self._vif." + self._serializefunc)(
			lvl, lendict, isext, islast)
	def lenof(self, memname):
		return eval("self._vif." + self._lenoffunc)(memname)

class VIntface(VBase):
	def __init__(self, dictData):
		super(VIntface, self).__init__(dictData)
		self._ports = []
		self._portsdict = {}
		self._inports = []
		self._outports = []
		self._inroports = []
		self._inttriggerports = []
		self._cfgports = []
		self._fixedports = []
		self._mirrorports = []
		self._trigbyclrintports = []
	def _addPort(self, dictData):
		port  = VPort(dictData)
		self._ports.append(port)
		self._portsdict[port.name] = port
		iodict = { 'input': self._inports, 'output': self._outports }
		iodict[port.iotype].append(port)
		mapdict = {
			'cfg': self._cfgports,
			'fixedV': self._fixedports,
			'intsrc': self._inttriggerports,
			'mirror': self._mirrorports,
			'inro': self._inroports,
			'trigbyclrint': self._trigbyclrintports
		}
		mapdict[port._get("ftype")].append(port)
	def getport(self, pname):
		return self._portsdict[pname]
	@property
	def lidx(self):
		if self._has("hidx"):
			return "0"
		if self._has("size"):
			return "0"
		return ""
	@property
	def hidx(self):
		if self._has("hidx"):
			return self._get("hidx")
		if self._has("size"):
			sstr = self._get("size")
			try:
				return str(int(sstr) - 1)
			except:
				return sstr + "-1"
		return ""
	@property
	def size(self):
		if self._has("hidx"):
			return self._get("hidx") + "+1"
		if self._has("size"):
			return self._get("size")
		return ""
	@property
	def reallidx(self):
		if self._has("realhidx"):
			return "0"
		if self._has("realsize"):
			return "0"
		return ""
	@property
	def realhidx(self):
		if self._has("realhidx"):
			return self._get("realhidx")
		if self._has("realsize"):
			sstr = self._get("realsize")
			try:
				return str(int(sstr) - 1)
			except:
				return sstr + "-1"
		return ""
	@property
	def realsize(self):
		if self._has("realsize"):
			return self._get("realsize")
		return self.size
	def serialize4port(self, lvl, lendict, isext, islast):
		ret = ""
		if self._has("comments"):
			ret += suppcomment(lvl, self.comments + " ports")
		hlwname = ["hbit", "lbit", "width"]
		hlsname = ["hidx", "lidx", "size"]
		lendict = self.__lendict(self._ports)
		if self._has("size"):
			ifsize = int(self.size)
			for ifidx in range(ifsize):
				iflast = (ifidx == ifsize-1);
				ret += suppcomment(lvl, self.name + ifidx2str(ifidx))
				for i, item in enumerate(self._ports):
					internal_islast = (islast and iflast and (i == len(self._ports) - 1))
					ret += suppline(lvl,
						stringfy2(
							item, hlwname,
							item, hlsname,
							self.name + ifidx2str(ifidx) + "_", item.name,
							item.iotype, item.wrtype, lendict, isext, internal_islast)
						)
		else:
			for i, item in enumerate(self._ports):
				internal_islast = (islast and (i == len(self._ports) - 1))
				ret += suppline(lvl,
					stringfy2(
						item, hlwname,
						item, hlsname,
						self.name + "_", item.name, item.iotype, item.wrtype,
						lendict, isext, internal_islast)
					)
		return ret
	def serialize4array(self, lvl, lendict, isext, islast):
		ret = ""
		if self._has("comments"):
			ret += suppcomment(lvl, self.comments + " array")
		hlwname = ["hbit", "lbit", "width"]
		hlsname = ["realhidx", "reallidx", "realsize"]
		if self._has("comments"):
			ret += suppcomment(lvl, self.comments + " array for input")
		for i, item in enumerate(self._inports):
			ret += suppline(lvl, stringfy2(
					item, hlwname,
					self, hlsname,
					str4array(self.name), item.name, item.iotype, "wire",
					self.__lendict(self._inports), isext, False
				))
		if self._has("comments"):
			ret += suppcomment(lvl, self.comments + " array for interrupt")
		for i, item in enumerate(self._inttriggerports):
			ret += suppline(lvl, stringfy2(
					VBase({}), hlwname,
					self, hlsname,
					str4intdly(self.name), item.name, item.iotype, "reg",
					self.__lendict(self._inttriggerports), False, False
				))
			ret += suppline(lvl, stringfy2(
					VBase({}), hlwname,
					self, hlsname,
					str4intena(self.name), item.name, item.iotype, "reg",
					self.__lendict(self._inttriggerports), False, False
				))
			ret += suppline(lvl, stringfy2(
					VBase({}), hlwname,
					self, hlsname,
					str4intsta(self.name), item.name, item.iotype, "reg",
					self.__lendict(self._inttriggerports), False, False
				))
			ret += suppline(lvl, stringfy2(
					VBase({}), hlwname,
					self, hlsname,
					str4intclr(self.name), item.name, item.iotype, "wire",
					self.__lendict(self._inttriggerports), False, False
				))
		if self._has("comments"):
			ret += suppcomment(lvl, self.comments + " array for config")
		for i, item in enumerate(self._cfgports):
			ret += suppline(lvl, stringfy2(
					item, hlwname,
					self, hlsname,
					str4array(self.name), item.name, item.iotype, "reg",
					self.__lendict(self._cfgports), False, False
				))
		if self._has("comments"):
			ret += suppcomment(lvl, self.comments + " array for fixed")
		for i, item in enumerate(self._fixedports):
			ret += suppline(lvl, stringfy2(
					item, hlwname,
					self, hlsname,
					str4array(self.name), item.name, item.iotype, "wire",
					self.__lendict(self._fixedports), False, False
				))
		if self._has("comments"):
			ret += suppcomment(lvl, self.comments + " array for trigbyclrint")
		for i, item in enumerate(self._trigbyclrintports):
			ret += suppline(lvl, stringfy2(
					item, hlwname,
					self, hlsname,
					str4array(self.name), item.name, item.iotype, "reg",
					self.__lendict(self._trigbyclrintports), False, False
				))
		if (self._has('outsync')):
			if self._has("comments"):
				ret += suppcomment(lvl, self.comments + " array for config (sync source)")
			for i, item in enumerate(self._cfgports):
				if item._get('sync') == 'false':
					ret += suppcomment(lvl, str4array(self.name, item.name))
				elif item._has('expr'):
					ret += suppcomment(lvl, str4array(self.name, item.name))
				else:
					ret += suppline(lvl, stringfy2(
							item, hlwname,
							self, hlsname,
							str4cfg(self.name), item.name, item.iotype, "reg",
							self.__lendict(self._cfgports), False, False
						))
		return ret
	def serialize4c2array(self, lvl, lendict, isext, islast):
		ret = ""
		if not self._has("size"):
			return
		ifsize = int(self.size)
		for ifidx in range(ifsize):
			ret += suppcomment(lvl,
				"convert interface {}{} to {}[{}]".format(
					self.name, ifidx2str(ifidx), self.name, ifidx2str(ifidx)))
			iflast = (ifidx == ifsize-1);
			ret += suppline(lvl, "if ({} > {}) begin: {}{}_to_array".format(
					self.realsize, str(ifidx), self.name, ifidx2str(ifidx)
				))
			lvl += 1
			for i, item in enumerate(self._inports):
				arstr = str4array(self.name, item.name, lenof(self._inports, "name"))
				ifstr = self.__getportstr4port(ifidx, item.name, lenof(self._inports, "name"))
				assignstr = "assign {}[{}] = /*input*/ {};".format(arstr, ifidx2str(ifidx), ifstr)
				ret += suppline(lvl, assignstr)
			for i, item in enumerate(self._mirrorports):
				srcstr = self.__getportstr4port(ifidx, item.mirror, lenof(self._mirrorports, "mirror"))
				dststr = self.__getportstr4port(ifidx, item.name, lenof(self._mirrorports, "name"))
				assignstr = "assign /*mirror*/ {} = /*output*/ {};".format(dststr, srcstr)
				ret += suppline(lvl, assignstr)
			for i, item in enumerate(self._fixedports):
				arstr = str4array(self.name, item.name, lenof(self._fixedports, "name"))
				ifstr = self.__getportstr4port(ifidx, item.name, lenof(self._fixedports, "name"))
				assignstr = "assign /*fixed */ {} = {}[{}];".format(ifstr, arstr, ifidx2str(ifidx))
				ret += suppline(lvl, assignstr)
			for i, item in enumerate(self._fixedports):
				srcstr = eval('self.' + item.fixedV)(ifidx)
				dststr = str4array(self.name, item.name, lenof(self._fixedports, "name"))
				assignstr = "assign /*fixed */ {}[{}] = {};".format(dststr, ifidx2str(ifidx), srcstr)
				ret += suppline(lvl, assignstr)
			for i, item in enumerate(self._cfgports):
				arstr = str4array(self.name, item.name, lenof(self._cfgports, "name"))
				ifstr = self.__getportstr4port(ifidx, item.name, lenof(self._cfgports, "name"))
				assignstr = "assign /*config*/ {} = {}[{}];".format(ifstr, arstr, ifidx2str(ifidx))
				ret += suppline(lvl, assignstr)
			for i, item in enumerate(self._trigbyclrintports):
				arstr = str4array(self.name, item.name, lenof(self._trigbyclrintports, "name"))
				ifstr = self.__getportstr4port(ifidx, item.name, lenof(self._trigbyclrintports, "name"))
				assignstr = "assign /*trigbyclrint*/ {} = {}[{}];".format(ifstr, arstr, ifidx2str(ifidx))
				ret += suppline(lvl, assignstr)
			lvl -= 1
			ret += suppline(lvl, "end")
			ret += suppline(lvl, 'else begin')
			lvl += 1
			for i, item in enumerate(self._outports):
				ifstr = self.__getportstr4port(ifidx, item.name, lenof(self._outports, "name"))
				assignstr = "assign /*output*/ {} = 0;".format(ifstr)
				ret += suppline(lvl, assignstr)
			lvl -= 1
			ret += suppline(lvl, 'end')
		ret += self.serialize4c2arrayloop(lvl, lendict, isext, islast)
		return ret
	def serialize4c2arrayloop(self, lvl, lendict, isext, islast):
		ret = ""
		ret += suppline(lvl, str4loopheader(0, self.realsize, 'sync_cfg_for_' + self.name))
		lvl += 1

		if (self._has('outsync')):
			ret += suppline(lvl, "always @ (posedge o_clk) begin")
			lvl += 1
			ret += suppline(lvl, "if (o_resetn == 1'b0) begin")
			lvl += 1
			for i, item in enumerate(self._cfgports):
				if item._get('sync') == 'true':
					srcstr = "{:<}".format(item.defV, lenof(self._cfgports, "defV"))
					dststr = str4array(self.name, item.name, lenof(self._cfgports, "name"))
					assignstr = "{}[i] <= {:<};".format(dststr, srcstr)
					ret += suppline(lvl, assignstr)
			lvl -= 1
			ret += suppline(lvl, "end")
			ret += suppline(lvl, "else if ({}) begin".format(self._get("outsync")))
			lvl += 1
			for i, item in enumerate(self._cfgports):
				if item._get('sync') == 'true':
					if item._has('expr'):
						srcstr = eval("self." + item._get('expr'))('i')
					else:
						srcstr = str4cfg(self.name, item.name, lenof(self._cfgports, "name")) + '[i]'
					dststr = str4array(self.name, item.name, lenof(self._cfgports, "name"))
					assignstr = "{}[i] <= {:<};".format(dststr, srcstr)
					ret += suppline(lvl, assignstr)
			lvl -= 1
			ret += suppline(lvl, "end")
			lvl -= 1
			ret += suppline(lvl, "end")

		for i, item in enumerate(self._inttriggerports):
			ret += suppline(lvl, "always @ (posedge o_clk) begin")
			lvl += 1
			ret += suppline(lvl, "if (o_resetn == 1'b0)")
			lvl += 1
			srcstr = str4array(self.name, item.name, lenof(self._inttriggerports, "name"))
			dststr = str4intdly(self.name, item.name, lenof(self._inttriggerports, "name"))
			ret += suppline(lvl, "{}[i] <= 0;".format(dststr))
			lvl -= 1
			ret += suppline(lvl, "else")
			lvl += 1
			ret += suppline(lvl, "{}[i] <= {}[i];".format(dststr, srcstr))
			lvl -= 1
			lvl -= 1
			ret += suppline(lvl, "end")

			ret += suppline(lvl, "always @ (posedge o_clk) begin")
			lvl += 1
			ret += suppline(lvl, "if (o_resetn == 1'b0)")
			srcstr = str4array(self.name, item.name)
			dststr = str4intsta(self.name, item.name)
			ret += suppline(lvl+1, "{}[i] <= 0;".format(dststr))
			ret += suppline(lvl, "else if ({}[i])".format(str4intclr(self.name, item.name)))
			ret += suppline(lvl+1, "{}[i] <= 0;".format(dststr))
			condstr = "{}[i] == {} && {}[i] == {}".format(
				str4intdly(self.name, item.name), "0" if item._get("trigint") == "posedge" else "1",
				str4array(self.name, item.name), "0" if item._get("trigint") == "negedge" else "1")
			ret += suppline(lvl, "else if ({})".format(condstr))
			ret += suppline(lvl+1, "{}[i] <= 1;".format(dststr))
			lvl -= 1
			ret += suppline(lvl, "end")

		for i, item in enumerate(self._trigbyclrintports):
			ret += suppline(lvl, "always @ (posedge o_clk) begin")
			lvl += 1
			ret += suppline(lvl, "if (o_resetn == 1'b0)")
			dststr = str4array(self.name, item.name)
			ret += suppline(lvl+1, "{}[i] <= 0;".format(dststr))
			ret += suppline(lvl, "else if ({}[i])".format(str4intclr(self.name, item._get("trigger"))))
			ret += suppline(lvl+1, "{}[i] <= 1;".format(dststr))
			if item._getMem("autoclr", "false") == "true":
				ret += suppline(lvl, "else")
				ret += suppline(lvl+1, "{}[i] <= 0;".format(dststr))
			lvl -= 1
			ret += suppline(lvl, "end")

		lvl -= 1
		ret += suppline(lvl, "end")
		return ret
	def __getportstr4port(self, ifidx, pname, namelen = 0):
		return "{}{}_{:<{}}".format(self.name, ifidx2str(ifidx), pname, namelen)

	def __lendict(self, portlist):
		lendict = {}
		for i in ['iotype', 'wrtype', 'name', 'lbit', 'hbit', 'hidx', 'lidx']:
			lendict[i] = lenof(portlist, i)
		for i in ['realhidx', 'reallidx']:
			lendict[i] = len(eval("self." + i))
		return lendict
	def lenof(self, memname):
		return 0

class VIfBlockram(VIntface):
	def __init__(self, dictdata):
		super(VIfBlockram, self).__init__(dictdata)
		self._addPort({'ftype': 'fixedV', "name": "init",  "iotype": "output", 'fixedV': 'getinit' })
		self._addPort({'ftype': 'fixedV', "name": "wr_en", "iotype": "output", 'fixedV': 'getwren' })
		self._addPort({'ftype': 'fixedV', "name": "data",  "iotype": "output", "width": dictdata["datawidth"], 'fixedV': 'getwrdata' })
		self._addPort({'ftype': 'inro', "name": "size",  "iotype": "input",  "hbit": dictdata["sizehbit"] })
	def getinit(self, ifidx):
		return self._get("init_val") + "[{}]".format(str(ifidx))
	def getwren(self, ifidx):
		return self._get("wr_en_val")
	def getwrdata(self, ifidx):
		return self._get('wr_data_val')

class VIfStreamCtl(VIntface):
	# bmpwidth, addrwidth, iwwidth, ihwidth, bufidxwidth, tswidth
	def __init__(self, dictData):
		super(VIfStreamCtl, self).__init__(dictData)

		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'in_resetn', 'sync': 'false' })

		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'out_resetn', 'sync': 'true', 'expr': 'calcout_resetn' })
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'fsa_disp_resetn', 'sync': 'true' })
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'dst_bmp', 'width': dictData["bmpwidth"], 'sync': 'true' })
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'width',   'width': dictData["iwwidth"], 'sync': 'true' })
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'height',  'width': dictData["ihwidth"], 'sync': 'true' })

		self._addPort({'ftype': 'fixedV',  'iotype': 'output', 'name': 'buf0_addr', 'fixedV': 'genbufaddr0', 'width': dictData["addrwidth"] })
		self._addPort({'ftype': 'fixedV',  'iotype': 'output', 'name': 'buf1_addr', 'fixedV': 'genbufaddr1', 'width': dictData["addrwidth"] })
		self._addPort({'ftype': 'fixedV',  'iotype': 'output', 'name': 'buf2_addr', 'fixedV': 'genbufaddr2', 'width': dictData["addrwidth"] })
		self._addPort({'ftype': 'fixedV',  'iotype': 'output', 'name': 'buf3_addr', 'fixedV': 'genbufaddr3', 'width': dictData["addrwidth"] })

		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'win_left',   'width': dictData["iwwidth"], 'sync': 'true' })
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'win_width',  'width': dictData["iwwidth"], 'sync': 'true' })
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'win_top',    'width': dictData["ihwidth"], 'sync': 'true' })
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'win_height', 'width': dictData["ihwidth"], 'sync': 'true' })

		self._addPort({'ftype': 'mirror',  'iotype': 'output', 'name': 'scale_src_width',  'mirror':'win_width',  'width': dictData["iwwidth"] })
		self._addPort({'ftype': 'mirror',  'iotype': 'output', 'name': 'scale_src_height', 'mirror':'win_height', 'width': dictData["ihwidth"] })
		self._addPort({'ftype': 'mirror',  'iotype': 'output', 'name': 'scale_dst_width',  'mirror':'dst_width',  'width': dictData["iwwidth"] })
		self._addPort({'ftype': 'mirror',  'iotype': 'output', 'name': 'scale_dst_height', 'mirror':'dst_height', 'width': dictData["ihwidth"] })

		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'dst_left',   'width': dictData["iwwidth"], 'sync': 'true' })
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'dst_width',  'width': dictData["iwwidth"], 'sync': 'true' })
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'dst_top',    'width': dictData["ihwidth"], 'sync': 'true' })
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'dst_height', 'width': dictData["ihwidth"], 'sync': 'true' })

		self._addPort({'ftype': 'intsrc',  'iotype': 'input',  'name': 'wr_done',    "trigint": "posedge" })
		self._addPort({'ftype': 'trigbyclrint',   'iotype': 'output', 'name': 'rd_en',      'trigger': "wr_done", 'autoclr': 'true' })
		self._addPort({'ftype': 'inro',    'iotype': 'input',  'name': 'rd_buf_idx', 'width': dictData["bufidxwidth"] })
		self._addPort({'ftype': 'inro',    'iotype': 'input',  'name': 'rd_buf_ts',  'width': dictData["tswidth"]     })

		self._addPort({'ftype': 'inro',    'iotype': 'input',  'name': 'lft_v',      'width': dictData['iwwidth'] })
		self._addPort({'ftype': 'inro',    'iotype': 'input',  'name': 'rt_v',       'width': dictData['iwwidth'] })
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'ref_data',   'width': dictData['ipwidth'], 'sync': 'true' })
	def calcout_resetn(self, ifidx):
		return '({}[{}] != 0)'.format(str4cfg(self.name, 'dst_bmp'), str(ifidx))
	def genbufaddr0(self, ifidx):
		return 'C_S{}_ADDR'.format(ifidx2str(ifidx))
	def genbufaddr1(self, ifidx):
		return 'C_S{0}_ADDR + C_S{0}_SIZE'.format(ifidx2str(ifidx))
	def genbufaddr2(self, ifidx):
		return 'C_S{0}_ADDR + C_S{0}_SIZE * 2'.format(ifidx2str(ifidx))
	def genbufaddr3(self, ifidx):
		return 'C_S{0}_ADDR + C_S{0}_SIZE * 3'.format(ifidx2str(ifidx))
class VIfMotorCtl(VIntface):
	def __init__(self, dictData):
		super(VIfMotorCtl, self).__init__(dictData)

		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'xen'})
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'xrst'})
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'stroke',   'width': dictData["stepwidth"] })
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'ms',       'width': dictData["mswidth"] })

		self._addPort({'ftype': 'intsrc', "trigint": "posedge",  'iotype': 'input',  'name': 'zpsign'})
		self._addPort({'ftype': 'intsrc', "trigint": "posedge",  'iotype': 'input',  'name': 'tpsign'})

		self._addPort({'ftype': 'intsrc', "trigint": "negedge", 'iotype': 'input',  'name': 'state'})
		self._addPort({'ftype': 'inro',    'iotype': 'input',  'name': 'rt_speed', 'width': dictData["speedwidth"] })

		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'start'})
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'stop'})
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'speed',    'width': dictData["speedwidth"] })
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'step',     'width': dictData["stepwidth"] })
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'dir'})
class VIfPwmCtl(VIntface):
	def __init__(self, dictData):
		super(VIfPwmCtl, self).__init__(dictData)

		self._addPort({'ftype': 'inro',    'iotype': 'input',  'name': 'def'})
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'en'})
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'numerator',   'width': dictData["ndwidth"] })
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'denominator', 'width': dictData["ndwidth"] })

class VIfReqCtl(VIntface):
	def __init__(self, dictData):
		super(VIfReqCtl, self).__init__(dictData)

		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'resetn'})
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'en'})
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'cmd',   'width': "32"})
		self._addPort({'ftype': 'cfg',     'iotype': 'output', 'name': 'param', 'width': "128"})
		self._addPort({'ftype': 'inro',    'iotype': 'input',  'name': 'done'})
		self._addPort({'ftype': 'inro',    'iotype': 'input',  'name': 'err',   'width': "32"})

class VerilogModuleFile:
	def __init__(self, name):
		self.name = name
		self.params = []
		self.localparams = []
		self.ports  = []
		self.intsigs  = []
		self.ifsigs   = []
		self.ifcvts   = []
		self._ifdict  = {}

	def addParam(self, param):
		self.params.append(VParam(param))
	def addParams(self, params):
		for i in params:
			self.addParam(i)
	def addLocalparam(self, param):
		self.localparams.append(VLocalparam(param))
	def addLocalparams(self, params):
		for i in params:
			self.addLocalparam(i)
	def addExtPort(self, port):
		self.ports.append(VPort(port))
	def addExtPorts(self, ports):
		for i in ports:
			self.addExtPort(i)
	def addIntPort(self, port):
		self.intsigs.append(VPort(port))
	def addExtInterface(self, iftype, dictdata):
		ifinst = eval(iftype)(dictdata)
		self._ifdict[ifinst.name] = ifinst
		self.ports.append(VIfProxy(ifinst, "serialize4port"))
		self.ifsigs.append(VIfProxy(ifinst, "serialize4array"))
		self.ifcvts.append(VIfProxy(ifinst, "serialize4c2array"))
	def getif(self, ifname):
		return self._ifdict[ifname]

	def gen_loop(self, lvl, size, loopname, contentstr):
		ret = ''
		ret += suppline(lvl, str4loopheader(0, size, loopname))
		ret += contentstr
		ret += suppline(lvl, str4looptail())
		return ret
	def gen_ind_reg(self, lvl, ridx, lbit, rwtype, ifname, pname, width='', dstlbit=''):
		intf = self.getif(ifname)
		port = intf.getport(pname)
		if port.iotype == 'input':
			dstname = str4array(intf.name, pname)
		elif intf._has('outsync'):
			dstname = str4cfg(intf.name, pname)
		else:
			dstname = str4array(intf.name, pname)
		regwdith = (port.width if width == '' else width)
		return drc_ind(lvl, ridx, lbit, regwdith, rwtype,
			dstname, dstlbit, intf.realsize, intf._get('indsel'))
	def save(self, path):
		with open(path, 'w') as fd:
			print(self.saveModule(), end="", file=fd)
	def saveModule(self):
		lvl = 0
		ret = ''
		ret += suppline(lvl, "module {0} # (".format(self.name))
		ret += self._saveCat(lvl+1, "params", True, self.params, ["dtype", 'name', 'defV'])
		ret += suppline(lvl, ') (')
		ret += self._saveCat(lvl+1, "ports", True, self.ports, ["iotype", 'wrtype', 'name', 'lbit', 'hbit', 'hidx', 'lidx'])
		ret += suppline(lvl, ');')
		ret += self._saveCat(lvl+1, "localparams", False, self.localparams, ['dtype', 'name', 'defV'])
		ret += self._saveCat(lvl+1, "internal sigs", False, self.intsigs, ['wrtype', 'name', 'lbit', 'hbit', 'hidx', 'lidx'])
		ret += self._saveCat(lvl+1, "ifsigs", False, self.ifsigs, ['wrtype', 'name', 'lbit', 'hbit', 'hidx', 'lidx'])
		ret += suppline(lvl+1, "genvar i;")
		ret += suppline(lvl+1, "integer j;")
		ret += suppline(lvl+1, "generate")
		ret += self._saveCat(lvl+1, "ifcvts", False, self.ifcvts, ['wrtype', 'name', 'lbit', 'hbit', 'hidx', 'lidx'])
		ret += self.saveCustom(lvl+1)
		ret += self.saveregdefs(lvl+1)
		ret += suppline(lvl+1, "endgenerate")
		ret += suppline(lvl, 'endmodule')
		return ret
	def _saveCat(self, lvl, cat, isext, listData, listMem):
		ret = ''
		ret += suppsection(lvl, cat)
		lendict = {}
		for i in listMem:
			lendict[i] = lenof(listData, i)
		for i, item in enumerate(listData):
			ret += item.serialize(lvl, lendict, isext, (i == len(listData)-1))
		return ret
	def saveCustom(self, lvl):
		return ''
	def saveregdefs(self, lvl):
		return ''

class VMFsctl(VerilogModuleFile):
	def __init__(self, filename):
		super(VMFsctl, self).__init__(filename)
		self.__addparams()
		self.__addports()
		self.__addlocalparams()
		self.__addintports()

	def __addparams(self):
		self.addParam({'dtype': 'integer', 'name': 'C_CORE_VERSION',      'defV': "32'hFF00FF00"})
		self.addParam({'dtype': 'integer', 'name': 'C_TS_WIDTH',          'defV': "64"          })
		self.addParam({'dtype': 'integer', 'name': 'C_DATA_WIDTH',        'defV': "32"          })
		self.addParam({'dtype': 'integer', 'name': 'C_REG_IDX_WIDTH',     'defV': "8"           })
		self.addParam({'dtype': 'integer', 'name': 'C_IMG_PBITS',         'defV': "8"          })
		self.addParam({'dtype': 'integer', 'name': 'C_IMG_WBITS',         'defV': "12"          })
		self.addParam({'dtype': 'integer', 'name': 'C_IMG_HBITS',         'defV': "12"          })
		self.addParam({'dtype': 'integer', 'name': 'C_IMG_WDEF',          'defV': "320"         })
		self.addParam({'dtype': 'integer', 'name': 'C_IMG_HDEF',          'defV': "240"         })
		self.addParam({'dtype': 'integer', 'name': 'C_STREAM_NBR',        'defV': "2"           })
		self.addParam({'dtype': 'integer', 'name': 'C_BUF_ADDR_WIDTH',    'defV': "32"          })
		self.addParam({'dtype': 'integer', 'name': 'C_BUF_IDX_WIDTH',     'defV': "2"           })
		self.addParam({'dtype': 'integer', 'name': 'C_ST_ADDR',           'defV': "32'h3D000000"})
		self.addParam({'dtype': 'integer', 'name': 'C_S0_ADDR',           'defV': "32'h3E000000"})
		self.addParam({'dtype': 'integer', 'name': 'C_S0_SIZE',           'defV': "32'h00100000"})
		self.addParam({'dtype': 'integer', 'name': 'C_S1_ADDR',           'defV': "32'h3E400000"})
		self.addParam({'dtype': 'integer', 'name': 'C_S1_SIZE',           'defV': "32'h00100000"})
		self.addParam({'dtype': 'integer', 'name': 'C_S2_ADDR',           'defV': "32'h3E800000"})
		self.addParam({'dtype': 'integer', 'name': 'C_S2_SIZE',           'defV': "32'h00100000"})
		self.addParam({'dtype': 'integer', 'name': 'C_S3_ADDR',           'defV': "32'h3EB00000"})
		self.addParam({'dtype': 'integer', 'name': 'C_S3_SIZE',           'defV': "32'h00100000"})
		self.addParam({'dtype': 'integer', 'name': 'C_S4_ADDR',           'defV': "32'h3F000000"})
		self.addParam({'dtype': 'integer', 'name': 'C_S4_SIZE',           'defV': "32'h00100000"})
		self.addParam({'dtype': 'integer', 'name': 'C_S5_ADDR',           'defV': "32'h3F400000"})
		self.addParam({'dtype': 'integer', 'name': 'C_S5_SIZE',           'defV': "32'h00100000"})
		self.addParam({'dtype': 'integer', 'name': 'C_S6_ADDR',           'defV': "32'h3F800000"})
		self.addParam({'dtype': 'integer', 'name': 'C_S6_SIZE',           'defV': "32'h00100000"})
		self.addParam({'dtype': 'integer', 'name': 'C_S7_ADDR',           'defV': "32'h3FC00000"})
		self.addParam({'dtype': 'integer', 'name': 'C_S7_SIZE',           'defV': "32'h00100000"})
		self.addParam({'dtype': 'integer', 'name': 'C_BR_INITOR_NBR',     'defV': "2"           , "comments": "block ram number, must be <= 8" })
		self.addParam({'dtype': 'integer', 'name': 'C_BR_ADDR_WIDTH',     'defV': "9"           })
		self.addParam({'dtype': 'integer', 'name': 'C_MOTOR_NBR',         'defV': "4"           , "comments": "motor number, must be <= 8" })
		self.addParam({'dtype': 'integer', 'name': 'C_ZPD_SEQ',           'defV': "8'b00000011" })
		self.addParam({'dtype': 'integer', 'name': 'C_SPEED_DATA_WIDTH',  'defV': "16"          })
		self.addParam({'dtype': 'integer', 'name': 'C_STEP_NUMBER_WIDTH', 'defV': "16"          })
		self.addParam({'dtype': 'integer', 'name': 'C_MICROSTEP_WIDTH',   'defV': "3"           })
		self.addParam({'dtype': 'integer', 'name': 'C_PWM_NBR',           'defV': "8"           })
		self.addParam({'dtype': 'integer', 'name': 'C_PWM_CNT_WIDTH',     'defV': "16"          })
		self.addParam({'dtype': 'integer', 'name': 'C_TEST',              'defV': "0"           })
	def __addports(self):
		self.addExtPort({'iotype': 'input',  'wrtype': 'wire', 'name': 'clk'})
		self.addExtPort({'iotype': 'input',  'wrtype': 'wire', 'name': 'resetn'})

		self.addExtPort({'iotype': 'input',  'wrtype': 'wire', 'name': 'rd_en'})
		self.addExtPort({'iotype': 'input',  'wrtype': 'wire', 'name': 'rd_addr', 'width': 'C_REG_IDX_WIDTH'})
		self.addExtPort({'iotype': 'output', 'wrtype': 'wire', 'name': 'rd_data', 'width': 'C_DATA_WIDTH'   })

		self.addExtPort({'iotype': 'input',  'wrtype': 'wire', 'name': 'wr_en'})
		self.addExtPort({'iotype': 'input',  'wrtype': 'wire', 'name': 'wr_addr', 'width': 'C_REG_IDX_WIDTH'})
		self.addExtPort({'iotype': 'input',  'wrtype': 'wire', 'name': 'wr_data', 'width': 'C_DATA_WIDTH'   })

		self.addExtPort({'iotype': 'input',  'wrtype': 'wire', 'name': 'o_clk'})
		self.addExtPort({'iotype': 'input',  'wrtype': 'wire', 'name': 'o_resetn'})
		self.addExtPort({'iotype': 'input',  'wrtype': 'wire', 'name': 'fsync'})
		self.addExtPort({'iotype': 'output', 'wrtype': 'wire', 'name': 'o_fsync'})
		self.addExtPort({'iotype': 'output', 'wrtype': 'wire', 'name': 'intr'})

		self.addExtPort({'iotype': 'output', 'wrtype': 'wire', 'name': 'out_ce'})
		self.addExtPort({'iotype': 'output', 'wrtype': 'wire', 'name': 'out_width',  'width': 'C_IMG_WBITS' })
		self.addExtPort({'iotype': 'output', 'wrtype': 'wire', 'name': 'out_height', 'width': 'C_IMG_HBITS' })

		self.addExtPort({'iotype': 'output', 'wrtype': 'wire', 'name': 'st_out_resetn'})
		self.addExtPort({'iotype': 'output', 'wrtype': 'wire', 'name': 'st_addr',   'width': 'C_BUF_ADDR_WIDTH'})
		self.addExtPort({'iotype': 'output', 'wrtype': 'wire', 'name': 'st_width',  'width': 'C_IMG_WBITS' })
		self.addExtPort({'iotype': 'output', 'wrtype': 'wire', 'name': 'st_height', 'width': 'C_IMG_HBITS' })

		self.addExtInterface("VIfStreamCtl", {
			"name": "s",
			"size": "8",
			"realsize": "C_STREAM_NBR",
			"comments": "stream interface",
			"outsync":  "update_stream_cfg",
			'indsel': 'stream_cfgsel',
			"bmpwidth": "C_STREAM_NBR",
			"iwwidth": "C_IMG_WBITS",
			"ihwidth": "C_IMG_HBITS",
			"ipwidth": "C_IMG_PBITS",
			"addrwidth": "C_BUF_ADDR_WIDTH",
			"bufidxwidth": "C_BUF_IDX_WIDTH",
			"tswidth": "C_TS_WIDTH"
		})
		self.addExtInterface("VIfBlockram", {
			"name": "br",
			"size": "8",
			"realsize": "C_BR_INITOR_NBR",
			"comments": "blockram interface",
			"datawidth": 'C_SPEED_DATA_WIDTH',
			'sizehbit' : 'C_BR_ADDR_WIDTH',
			'indsel'   : 'br_sel',
			'init_val' : 'br_sel',
			'wr_en_val': 'br_wre',
			'wr_data_val': 'br_wrd'
		})
		self.addExtInterface("VIfMotorCtl", {
			"name": "motor",
			"size": "8",
			"realsize": "C_MOTOR_NBR",
			"comments": "motor interface",
			"speedwidth": "C_SPEED_DATA_WIDTH",
			"stepwidth": "C_STEP_NUMBER_WIDTH",
			"mswidth": "C_MICROSTEP_WIDTH",
			'indsel': 'motor_sel'
		})
		self.addExtInterface("VIfPwmCtl", {
			"name": "pwm",
			"size": "8",
			"realsize": "C_PWM_NBR",
			"comments": "pwm interface",
			"ndwidth": 'C_PWM_CNT_WIDTH',
			'indsel': 'pwm_sel'
		})

		self.addExtInterface("VIfReqCtl", {
			"name": "reqctl",
			"size": "1",
			"realsize": "1",
			"comments": "request to fscpu"
		})
	def __addlocalparams(self):
		self.addLocalparam({ "name": "C_REG_NUM", "comments": "register number", "defV": "2**C_REG_IDX_WIDTH" })

	def __addintports(self):
		self.addIntPort({
			"name": "slv_reg",
			"width": "C_DATA_WIDTH",
			"size": "C_REG_NUM",
			'comments': "reg container signals"
		})
		self.addIntPort({
			"name": "wre_sync",
			"wrtype": "reg",
			"width": "C_REG_NUM",
			'comments': "write reg enable"
		})
		self.addIntPort({
			"name": "wrd_sync",
			"wrtype": "reg",
			"width": "C_DATA_WIDTH",
			'comments': "write reg data"
		})
		self.addIntPort({
			"name": "stream_int",
			"wrtype": "reg",
			'comments': "stream interrupt"
		})
		self.addIntPort({
			"name": "update_stream_cfg",
			"wrtype": "reg",
			'comments': "enable update stream configuration"
		})
		self.addIntPort({
			"name": "stream_cfging",
			"wrtype": "reg",
			'comments': "configuring stream"
		})
		self.addIntPort({
			"name": "stream_cfgsel",
			"wrtype": "reg",
			'size': 'C_REG_NUM',
			'comments': "select stream for configure"
		})
		self.addIntPort({
			"name": "br_sel",
			"wrtype": "reg",
			'width': 'C_BR_INITOR_NBR',
			'comments': "blockram write enable"
		})
		self.addIntPort({
			"name": "br_wre",
			"wrtype": "reg",
			'comments': "blockram write enable"
		})
		self.addIntPort({
			"name": "br_wrd",
			"wrtype": "reg",
			'width': 'C_SPEED_DATA_WIDTH',
			'comments': "blockram write enable"
		})
		self.addIntPort({
			"name": "motor_int",
			"wrtype": "reg",
			'comments': "motor interrupt"
		})
		self.addIntPort({
			"name": "motor_sel",
			"wrtype": "reg",
			'width': 'C_MOTOR_NBR',
			'comments': "select motor for configure"
		})
		self.addIntPort({
			"name": "pwm_sel",
			"wrtype": "reg",
			'width': 'C_PWM_NBR',
			'comments': "select pwm for configure"
		})
	def saveCustom(self, lvl):
		ret = ''
		ret += suppsection(lvl, 'misc logic')
		ret += suppcomment(lvl, 'register read logic')
		ret += suppline(lvl, 'reg[C_DATA_WIDTH-1:0] r_rd_data;')
		ret += suppline(lvl, 'assign rd_data = r_rd_data;')
		ret += suppline(lvl, 'always @ (posedge o_clk)')
		ret += suppline(lvl+1, 'if (rd_en)')
		ret += suppline(lvl+2, 'r_rd_data <= slv_reg[rd_addr];')

		ret += suppcomment(lvl, 'out width/height')
		ret += suppline(lvl, 'assign out_width  = C_IMG_WDEF;')
		ret += suppline(lvl, 'assign out_height = C_IMG_HDEF;')

		ret += suppcomment(lvl, 'st_out_resetn')
		ret += suppline(lvl, 'assign st_out_resetn = 1;')

		ret += suppcomment(lvl, 'st_addr')
		ret += suppline(lvl, 'assign st_addr = C_ST_ADDR;')

		ret += suppcomment(lvl, 'st width/height')
		ret += suppline(lvl, 'assign st_width  = out_width;')
		ret += suppline(lvl, 'assign st_height = out_height;')

		ret += suppcomment(lvl, 'out_ce')
		ret += drc_defreg(lvl, 1, 'r_stream_en', 'reg')
		ret += drc_trig(lvl, 'r_stream_en', 'o_fsync', 0, 'false')
		ret += suppline(lvl, 'assign out_ce = r_stream_en;')

		ret += suppcomment(lvl, 'sync register write enable signals')
		ret += suppcomment(lvl, '@NOTE: freq_oclk > 4 freq_clk')
		ret += suppline(lvl, 'reg clk_d1;')
		ret += suppline(lvl, 'reg wr_en_d1;')
		ret += suppline(lvl, 'reg[C_DATA_WIDTH-1:0]    wr_data_d1;')
		ret += suppline(lvl, 'reg[C_REG_IDX_WIDTH-1:0] wr_addr_d1;')
		ret += suppline(lvl, str4alwaysbegin())
		ret += suppline(lvl+1, 'clk_d1     <= clk;')
		ret += suppline(lvl+1, 'wr_en_d1   <= wr_en;')
		ret += suppline(lvl+1, 'wr_data_d1 <= wr_data;')
		ret += suppline(lvl+1, 'wr_addr_d1 <= wr_addr;')
		ret += suppline(lvl, str4alwaysend())
		ret += suppline(lvl, 'reg wre_d2;')
		ret += suppline(lvl, 'reg[C_DATA_WIDTH-1:0]    wr_data_d2;')
		ret += suppline(lvl, 'reg[C_REG_NUM-1:0]       wr_addr_d2;')
		ret += suppline(lvl, str4alwaysbegin())
		ret += suppline(lvl+1, 'wre_d2     <= (clk && ~clk_d1 && wr_en_d1);')
		ret += suppline(lvl+1, 'wr_data_d2 <= wr_data_d1;')
		ret += suppline(lvl+1, 'wr_addr_d2 <= wr_addr_d1;')
		ret += suppline(lvl, str4alwaysend())
		ret += suppline(lvl, 'always @ (posedge o_clk)')
		ret += suppline(lvl+1, 'wrd_sync <= wr_data_d2;')
		ret += suppline(lvl, 'for (i = 0; i < C_REG_NUM; i = i + 1)')
		ret += suppline(lvl+1, 'always @ (posedge o_clk)')
		ret += suppline(lvl+2, 'wre_sync[i]     <= (wre_d2 && (wr_addr_d2 == i));')

		ret += suppcomment(lvl, 'fsync delay')
		ret += suppline(lvl, 'reg[1:0] fsync_dly;')
		ret += suppline(lvl, str4alwaysbegin())
		ret += suppline(lvl+1, 'if (o_resetn == 1\'b0)')
		ret += suppline(lvl+2, 'fsync_dly <= 2\'b00;')
		ret += suppline(lvl+1, 'else')
		ret += suppline(lvl+2, 'fsync_dly[1:0] <= {fsync_dly[0], fsync};')
		ret += suppline(lvl, str4alwaysend())

		ret += suppcomment(lvl, 'fsync_posedge and update_stream_cfg')
		ret += suppline(lvl, 'reg fsync_posedge;')
		ret += suppline(lvl, str4alwaysbegin())
		ret += suppline(lvl+1, 'if (o_resetn == 1\'b0) begin')
		ret += suppline(lvl+2, 'fsync_posedge     <= 1\'b0;')
		ret += suppline(lvl+2, 'update_stream_cfg <= 1\'b0;')
		ret += suppline(lvl+1, 'end')
		ret += suppline(lvl+1, 'else if (fsync_dly == 2\'b01) begin')
		ret += suppline(lvl+2, 'fsync_posedge     <= 1\'b1;')
		ret += suppline(lvl+2, 'update_stream_cfg <= ~stream_cfging;')
		ret += suppline(lvl+1, 'end')
		ret += suppline(lvl+1, 'else begin')
		ret += suppline(lvl+2, 'fsync_posedge     <= 1\'b0;')
		ret += suppline(lvl+2, 'update_stream_cfg <= 1\'b0;')
		ret += suppline(lvl+1, 'end')
		ret += suppline(lvl, str4alwaysend())

		ret += suppcomment(lvl, 'o_fsync')
		ret += suppcomment(lvl, '@NOTE: o_fsync is delay 1 clock comparing with fsync_posedge,')
		ret += suppcomment(lvl, '       i.e. moving config is appeared same time as assigning o_fsync.')
		ret += suppline(lvl, 'reg r_o_fsync;')
		ret += suppline(lvl, 'assign o_fsync = r_o_fsync;')
		ret += suppline(lvl, str4alwaysbegin())
		ret += suppline(lvl+1, 'if (o_resetn == 1\'b0)')
		ret += suppline(lvl+2, 'r_o_fsync <= 1\'b0;')
		ret += suppline(lvl+1, 'else')
		ret += suppline(lvl+2, 'r_o_fsync <= fsync_posedge;')
		ret += suppline(lvl, str4alwaysend())

		return ret
	def saveregdefs(self, lvl):
		ret  = ''
		ret += suppsection(lvl, 'register definition')
		ridx = 0

		intf = self.getif('s')
		stream_int_ena_ridx = ridx
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_loop(lvl, intf.realsize, str4regdef(ridx),
				drc_int_ena(lvl+1, ridx+0, "i*4", str4intena(intf.name,'wr_done') + '[i]'))
		ridx += 1
		stream_int_sta_ridx = ridx
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_loop(lvl, intf.realsize, str4regdef(ridx),
				drc_int_sta(lvl+1, ridx, "i*4", str4intsta(intf.name,'wr_done') + '[i]'))
		ret += self.gen_loop(lvl, intf.realsize, 'loop4' + str4intclr(intf.name,'wr_done'),
				drc_int_clr(lvl+1, ridx, "i*4", str4intclr(intf.name,'wr_done') + '[i]'))
		ret += suppline(lvl, str4alwaysbegin())
		ret += suppline(lvl+1, 'stream_int <= ((slv_reg[{}] & slv_reg[{}]) != 0);'.format(
				stream_int_ena_ridx, stream_int_sta_ridx
			))
		ret += suppline(lvl, str4alwaysend())

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_loop(lvl, intf.realsize, 'loop4' + str4cfg(intf.name, 'in_resetn'),
				drc_rw(lvl+1, ridx, 'i', 1, str4array(intf.name, 'in_resetn') + '[i]'))

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_loop(lvl, intf.realsize, 'loop4' + str4cfg(intf.name, 'fsa_disp_resetn'),
				drc_rw(lvl+1, ridx, 'i', 1, str4cfg(intf.name, 'fsa_disp_resetn') + '[i]'))

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += drc_rw(lvl, ridx, 0, 1, 'stream_cfging')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_loop(lvl, intf.realsize, str4regdef(ridx),
				drc_rw(lvl+1, ridx, "i", 1, 'stream_cfgsel[i]'))

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'rw', 's', 'dst_bmp')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'rw', 's', 'height')
		ret += self.gen_ind_reg(lvl, ridx, 16, 'rw', 's', 'width')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'rw', 's', 'win_top')
		ret += self.gen_ind_reg(lvl, ridx, 16, 'rw', 's', 'win_left')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'rw', 's', 'win_height')
		ret += self.gen_ind_reg(lvl, ridx, 16, 'rw', 's', 'win_width')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'rw', 's', 'dst_top')
		ret += self.gen_ind_reg(lvl, ridx, 16, 'rw', 's', 'dst_left')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'rw', 's', 'dst_height')
		ret += self.gen_ind_reg(lvl, ridx, 16, 'rw', 's', 'dst_width')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'ro', 's', 'rd_buf_idx')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'ro', 's', 'rd_buf_ts', 32, 0)

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'ro', 's', 'rd_buf_ts', 32, 32)

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'ro', 's', 'lft_v')
		ret += self.gen_ind_reg(lvl, ridx, 16, 'ro', 's', 'rt_v')
		#ret += suppreadreg0(lvl, ridx)

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'rw', 's', 'ref_data')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)

		intf = self.getif('br')
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_loop(lvl, intf.realsize, str4regdef(ridx),
				drc_rw(lvl+1, ridx, "i", 1, 'br_sel[i]'))

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += drc_wo(lvl, ridx, 0, 'C_SPEED_DATA_WIDTH', 'br_wrd')
		ret += drc_trig(lvl, 'br_wre', 'wre_sync[{}]'.format(str(ridx)), 0, 'true')
		ret += suppreadreg0(lvl, ridx)

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'ro', 'br', 'size')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)

		intf = self.getif('motor')
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_loop(lvl, intf.realsize, str4regdef(ridx),
			  drc_rw(lvl+1, ridx, 'i*4', 1, str4array(intf.name, 'xen') + '[i]')
			+ drc_rw(lvl+1, ridx, 'i*4+1', 1, str4array(intf.name, 'xrst') + '[i]'))

		ridx += 1
		motor_int_ena_ridx = ridx
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_loop(lvl, intf.realsize, str4regdef(ridx),
			  drc_int_ena(lvl+1, ridx, "i*4+0", str4intena(intf.name,'zpsign') + '[i]')
			+ drc_int_ena(lvl+1, ridx, "i*4+1", str4intena(intf.name,'tpsign') + '[i]')
			+ drc_int_ena(lvl+1, ridx, "i*4+2", str4intena(intf.name,'state') + '[i]'))

		ridx += 1
		motor_int_sta_ridx = ridx
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_loop(lvl, intf.realsize, str4regdef(ridx),
			  drc_int_sta(lvl+1, ridx, "i*4+0", str4intsta(intf.name,'zpsign') + '[i]')
			+ drc_int_sta(lvl+1, ridx, "i*4+1", str4intsta(intf.name,'tpsign') + '[i]')
			+ drc_int_sta(lvl+1, ridx, "i*4+2", str4intsta(intf.name,'state') + '[i]'))
		ret += self.gen_loop(lvl, intf.realsize, 'loop4' + str4intclr(intf.name,'motor'),
			  drc_int_clr(lvl+1, ridx, "i*4+0", str4intclr(intf.name,'zpsign') + '[i]')
			+ drc_int_clr(lvl+1, ridx, "i*4+1", str4intclr(intf.name,'tpsign') + '[i]')
			+ drc_int_clr(lvl+1, ridx, "i*4+2", str4intclr(intf.name,'state') + '[i]'))
		ret += suppline(lvl, str4alwaysbegin())
		ret += suppline(lvl+1, 'motor_int <= ((slv_reg[{}] & slv_reg[{}]) != 0);'.format(
				motor_int_ena_ridx, motor_int_sta_ridx
			))
		ret += suppline(lvl, str4alwaysend())

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_loop(lvl, intf.realsize, str4regdef(ridx),
			  drc_ro(lvl+1, ridx, 'i*4+0', 1, str4array(intf.name, 'zpsign') + '[i]')
			+ drc_ro(lvl+1, ridx, 'i*4+1', 1, str4array(intf.name, 'tpsign') + '[i]')
			+ drc_ro(lvl+1, ridx, 'i*4+2', 1, str4array(intf.name, 'state') + '[i]'))

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_loop(lvl, intf.realsize, str4regdef(ridx),
			  drc_wo(lvl+1, ridx, 'i*4+0', 1, str4array(intf.name, 'start') + '[i]', 0, 'true')
			+ drc_wo(lvl+1, ridx, 'i*4+1', 1, str4array(intf.name, 'stop') + '[i]', 0, 'true'))
		ret += suppreadreg0(lvl, ridx)

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_loop(lvl, intf.realsize, str4regdef(ridx),
				drc_rw(lvl+1, ridx, "i", 1, 'motor_sel[i]'))

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'rw', 'motor', 'ms')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'rw', 'motor', 'stroke')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'rw', 'motor', 'dir')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'rw', 'motor', 'step')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'rw', 'motor', 'speed')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)

		intf = self.getif('pwm')
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_loop(lvl, intf.realsize, str4regdef(ridx),
			drc_ro(lvl+1, ridx, 'i', 1, str4array(intf.name, 'def') + '[i]'))

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_loop(lvl, intf.realsize, str4regdef(ridx),
			drc_rw(lvl+1, ridx, 'i', 1, str4array(intf.name, 'en') + '[i]'))

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_loop(lvl, intf.realsize, str4regdef(ridx),
				drc_rw(lvl+1, ridx, "i", 1, 'pwm_sel[i]'))

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'rw', 'pwm', 'denominator')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += self.gen_ind_reg(lvl, ridx, 0, 'rw', 'pwm', 'numerator')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)

		ridx += 1
		all_int_ridx = ridx
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += drc_ro(lvl, ridx, 0, 1, 'stream_int')
		ret += drc_ro(lvl, ridx, 1, 1, 'motor_int')
		ret += suppline(lvl, 'assign intr = (slv_reg[{}] != 0);'.format(all_int_ridx))

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)
		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += suppreadreg0(lvl, ridx)


		intf = self.getif('reqctl')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += drc_rw(lvl, ridx, 0, 1, str4array(intf.name, 'resetn') + '[0]')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += drc_ro(lvl, ridx, 0, 1, str4array(intf.name, 'done') + '[0]')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += drc_ro(lvl, ridx, 0, 32, str4array(intf.name, 'err') + '[0]')

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += drc_wo(lvl, ridx, 0, 1, str4array(intf.name, 'en') + '[0]', 0, 'true')
		#ret += suppreadreg0(lvl, ridx)

		ridx += 1
		ret += suppcomment(lvl, str4regdefcomment(ridx))
		ret += drc_wo(lvl, ridx, 0, 1, str4array(intf.name, 'cmd') + '[0]', 0, 'true')
		#ret += suppreadreg0(lvl, ridx)

		for i in range(0,128,32):
			ridx += 1
			ret += suppcomment(lvl, str4regdefcomment(ridx))
			strtemp = '[' + str(i + 32 - 1) + ':' + str(i) + ']'
			ret += drc_wo(lvl, ridx, 0, 32, str4array(intf.name, 'param') + '[0]' + strtemp, 0, 'true')
			#ret += suppreadreg0(lvl, ridx)

		ridx += 1
		ret += suppline(lvl, str4loopheader(ridx, 'C_REG_NUM', 'remain_regs', 'i'))
		ret += suppreadreg0(lvl+1, 'i')
		ret += suppline(lvl, str4looptail())

		return ret
def main(argv):
	m = VMFsctl("fsctl")
	m.save(get_scirpt_dir() / "../ip/fsctl/src/fsctl.v")

if __name__ == "__main__":
	main(sys.argv)
