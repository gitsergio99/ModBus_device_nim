import mbserver
import std/[math,sequtils,strutils]
import modbusutil
#import asyncdispatch
var
    plc1:ModBus_Device
    msg:string
    chr:seq[char] = @['\x00','\x00','\xEF','\x09']
    i:seq[int16] = @[10,0,16,452,8833,2]
plc1.hregs.sets(0,@[int16(10),int16(20),int16(30),int16(40),int16(50),int16(60)])
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
echo char_adr_to_int(chr[3],chr[2])
echo seq_int16_to_seq_chr(i)