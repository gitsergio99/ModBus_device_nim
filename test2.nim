import std/[sequtils,strutils,strformat,bitops,asyncnet, asyncdispatch,net]
import mbtcpdevicefull

var
    content:int16 = 0x0012
    and_mask:int16 = 0x00F2
    or_mask:int16 = 0x0025
    res:int16 = 0
    not_and_mask:int16 = not and_mask
    plc1:ModBus_Device
    
res = bitor(bitand(content,and_mask),bitand(or_mask,not_and_mask))
#echo res.toHex
plc1.modbus_adr=1
plc1.hregs.sets(0,@[int16(10),int16(20),int16(30),int16(40),int16(50),int16(60),int16(70),int16(80),int16(90),int16(100)])
plc1.iregs.sets(0,@[int16(15),int16(25),int16(35),int16(45),int16(55),int16(65),int16(75),int16(85),int16(95),int16(105)])
plc1.coils.sets(0,@[true,false,true,false,true,false,true,false,true,false])
plc1.di.sets(0,@[true,true,true,false,false,true,true,true,true,true,true,true,true])
var p:ptr[ModBus_Device] = plc1.addr
#run_srv_synh(plc1,502)
asyncCheck run_srv_asynch(p,502)
runForever()