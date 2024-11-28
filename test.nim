import mbserver
import std/math
#import asyncdispatch
var
    plc1:ModBus_Device


proc do_this() =
    echo plc1.hregs(0,10)
    echo "Niga"


set_hregs(plc1,0,@[uint16(10),uint16(20),uint16(30),uint16(40),uint16(50),uint16(60)])
echo plc1.hregs(0,10)
echo ceilDiv(5,3)