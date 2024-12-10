import taskpools
import std/[sequtils,strutils,strformat,bitops,asyncnet, asyncdispatch,net,os]
import mbtcpdevicefull

var
    shared_var:int = 0
    plc1:ModBus_Device

plc1.modbus_adr=1
plc1.logging=true
plc1.hregs.sets(0,@[int16(10),int16(20),int16(30),int16(40),int16(50),int16(60),int16(70),int16(80),int16(90),int16(100)])
plc1.iregs.sets(0,@[int16(15),int16(25),int16(35),int16(45),int16(55),int16(65),int16(75),int16(85),int16(95),int16(105)])
plc1.coils.sets(0,@[true,false,true,false,true,false,true,false,true,false])
plc1.di.sets(0,@[true,true,true,false,false,true,true,true,true,true,true,true,true])
var p:ptr[ModBus_Device] = plc1.addr

proc random_task() =
    asyncCheck run_srv_asynch(p,502)
    runForever()

proc main_task() =
    var
        #ntreads = countProcessors()
        hr:seq[int16] = @[]
        tp = Taskpool.new(num_threads = 4)
    spawn(tp,random_task())
    while true:
        hr = plc1.hregs.gets(0,30)
        #echo fmt"curren state is {hr}"
        sleep(2000)

main_task()