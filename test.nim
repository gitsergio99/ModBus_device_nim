import mbserver
import std/[math,sequtils]
#import asyncdispatch
var
    plc1:ModBus_Device
    msg:string

plc1.hregs.sets(0,@[uint16(10),uint16(20),uint16(30),uint16(40),uint16(50),uint16(60)])
plc1.coils.sets(5,@[true,true,true,true,true])
#set_hregs(plc1,0,@[uint16(10),uint16(20),uint16(30),uint16(40),uint16(50),uint16(60)])
echo plc1.hregs.gets(0,10)
echo plc1.coils.gets(0,10)
plc1.modbus_adr=10
echo plc1.modbus_adr
#echo ceilDiv(5,3)
apply(@['g','o','o','d'],proc(it:char) = msg.add(it))
echo msg
echo "".len