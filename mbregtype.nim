import std/[tables,sequtils]
type
    ModBus_Device* = object
        device_name:string = "plc1"
        logging:bool = false
        modbus_adr:uint8 = 1
        auto_save_state:bool = false
        hregs* = initTable[int,seq[int16]]()
        iregs* = initTable[int,seq[int16]]()
        coils* = initTable[int,seq[bool]]()
        di* = initTable[int,seq[bool]]()

proc initModBus_Device* (self: var ModBus_Device,name:string,log:bool,adr:uint8,save:bool,hr:seq[array[2,int]],ir:seq[array[2,int]],co:seq[array[2,int]],di:seq[array[2,int]]) =
    var
        hold = initTable[int,seq[int16]]()
        ireg = initTable[int,seq[int16]]()
        col = initTable[int,seq[bool]]()
        dis = initTable[int,seq[bool]]()
    self.auto_save_state = save
    self.device_name = name
    self.logging = log
    self.modbus_adr = adr
    for el in hr:
        hold.add(el[0],newSeq[int16](el[1]))
    for el in ir:
        ireg.add(el[0],newSeq[int16](el[1]))
    for el in co:
        col.add(el[0],newSeq[bool](el[1]))
    for el in di:
        dis.add(el[0],newSeq[bool](el[1]))
    self.hregs = hold
    self.iregs = ireg
    self.coils = col
    self.di = dis

template sets* [T] (regs:T,adr:int,val:untyped): untyped =
    var ret:bool = false
    for el in regs.pairs:
        if adr >= el[0] and (adr + val.len) <= (el[0] + el[1].len):
            for i in 0..val.len-1:
                regs[el[0]][(adr-el[0])+i] = val[i]
            ret = true
    ret