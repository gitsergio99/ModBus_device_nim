import taskpools
import std/[sequtils,strutils,strformat,bitops,asyncnet, asyncdispatch,net,os]
import mbtcpdevicefull

var
    shared_var:int = 0
    plc1:ModBus_Device

plc1.modbus_adr=1
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
        echo fmt"curren state is {hr}"
        sleep(2000)

main_task()