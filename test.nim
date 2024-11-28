import mbserver
var
    plc1:ModBus_Device

set_hregs(plc1,0,@[uint16(10),uint16(20),uint16(30),uint16(40),uint16(50),uint16(60)])
echo get_hregs(plc1,1)