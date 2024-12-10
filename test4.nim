import std/[net,times,strutils,marshal,streams]
import mbtcpdevicefull

var name_f:string
var sq:seq[int] = @[10,20,30,40,50]
var plc1:ModBus_Device
var streamf = newFileStream("state.json",fmWrite)

var plc2:ModBus_Device

plc1.modbus_adr=1
plc1.logging=true
plc1.hregs.sets(0,@[int16(10),int16(20),int16(30),int16(40),int16(50),int16(60),int16(70),int16(80),int16(90),int16(100)])
plc1.iregs.sets(0,@[int16(15),int16(25),int16(35),int16(45),int16(55),int16(65),int16(75),int16(85),int16(95),int16(105)])
plc1.coils.sets(0,@[true,false,true,false,true,false,true,false,true,false])
plc1.di.sets(0,@[true,true,true,false,false,true,true,true,true,true,true,true,true])

proc dt_to_name_file():string =
  let dt = now()
  let year = dt.year
  let mm = dt.month.ord
  let dd = dt.monthday
  let hh = dt.hour
  let mint = dt.minute
  let sec = dt.second
  result = intToStr(year)&'_'&intToStr(mm)&'_'&intToStr(dd)&'_'&intToStr(hh)&'_'&intToStr(mint)&'_'&intToStr(sec)&".log"

#let j = $$plc1
store(streamf,plc1)
streamf.close()
var streamf2 = newFileStream("state.json",fmRead)
load(streamf2,plc2)
echo plc2.logging
streamf2.close()
#echo dt_to_name_file()