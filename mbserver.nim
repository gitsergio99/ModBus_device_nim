import modbusutil

type
    ModBus_Device* = object
        hregs:array[0..65535,uint16]
        iregs:array[0..65535,uint16]
        coils:array[0..65535,bool]
        di:array[0..65535,bool]
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

proc set_hregs*(mb:var ModBus_Device,adr:int,val:seq[uint16])  =
    #set holding registers directly
    for i in 0..val.len-1:
        mb.hregs[adr+i] = val[i]
proc set_iregs*(mb:var ModBus_Device,adr:int,val:seq[uint16])  =
    #set input registers directly
    for i in 0..val.len-1:
        mb.iregs[adr+i] = val[i]
proc set_coils*(mb:var ModBus_Device,adr:int,val:seq[bool])  =
        #set coils  directly
    for i in 0..val.len-1:
        mb.coils[adr+i] = val[i]
proc set_di*(mb:var ModBus_Device,adr:int,val:seq[bool])  =
        #set discret inputs registers directly
    for i in 0..val.len-1:
        mb.di[adr+i] = val[i]

proc get_hregs*(mb: ModBus_Device,adr:int):uint16  =
    #get holding registers directly
    return mb.hregs[adr]
proc get_iregs*(mb: ModBus_Device,adr:int):uint16 =
    #get input registers directly
    return mb.iregs[adr]
proc get_coils*(mb: ModBus_Device,adr:int):bool  =
        #get coils  directly
    return mb.coils[adr]
proc get_di*(mb:ModBus_Device,adr:int):bool  =
        #get discret inputs registers directly
    return mb.di[adr]