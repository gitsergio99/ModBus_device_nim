import modbusutil
#import asyncdispatch


type
    ModBus_Device* = object
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
