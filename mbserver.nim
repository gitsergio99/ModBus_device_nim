import modbusutil
import std/[sequtils]
#import asyncdispatch


type
    ModBus_Device* = object
        modbus_adr:uint8 = 1
        hregs*:array[0..65535,uint16]
        iregs*:array[0..65535,uint16]
        coils*:array[0..65535,bool]
        di*:array[0..65535,bool]
        #allowed regions of holding registers: default all 65536 registers allowed
        # [start_address,quantity]
        allowed_hregs:seq[array[0..1,int]] = @[[0,65536]] 
        allowing_hregs:bool = false # if false allowed_hregs no matter
        allowed_iregs:seq[array[0..1,int]] = @[[0,65536]] 
        allowing_iregs:bool = false # if false allowed_iregs no matter
        allowed_coils:seq[array[0..1,int]] = @[[0,65536]] 
        allowing_coils:bool = false # if false allowed_coils no matter
        allowed_di:seq[array[0..1,int]] = @[[0,65536]] 
        allowing_di:bool = false # if false allowed_di no matter
#set and get procs for regs memory

template sets* [T] (regs:T,adr:int,val:untyped): untyped =
    for i in 0..val.len-1:
        regs[adr+i] = val[i]

template gets* [T] (regs:T,adr:int,quantity:int): untyped =
    regs[adr..adr+quantity-1]

proc `modbus_adr=`*(self: var ModBus_Device,adr:uint8) =
    self.modbus_adr = adr

proc `modbus_adr`*(self:ModBus_Device):uint8 =
    self.modbus_adr

method response*(self:ModBus_Device,ask_data:seq[char]): string =
    var
        supported_fn:array[0..9,char] = ['\x01','\x02','\x23','\x04','\x05','\x06','\x0F','\x10','\x16','\x17']
        mbap_strater:seq[char] = ask_data[0..3]
        tmp_adr:char = ask_data[6]
        tmp_fn:char = ask_data[7]
        outer_str:string
        outer_seq:seq[char] = @[]

    if tmp_adr == cast_c(self.modbus_adr):
        if tmp_fn in supported_fn:
            outer_str = ""
        else:
            outer_seq.add(mbap_strater)
            outer_seq.add('\x03')
            outer_seq.add(tmp_adr)
            outer_seq.add(cast_c(cast[uint8](tmp_fn)+128))
            outer_seq.add('\x01')
            apply(outer_seq,proc(it:char) = outer_str.add(it))
    else:
        outer_str = ""
    
    return outer_str
    


    
