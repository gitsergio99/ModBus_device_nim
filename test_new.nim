import taskpools
import std/[sequtils,strutils,strformat,bitops,asyncnet, asyncdispatch,net,os]
import mbdevice

var
    shared_var:int = 0
    plc1:ModBus_Device

initModBus_Device(plc1,"plc1",true,uint8(1),true, @[[0,10],[100,5]], @[[0,10],[100,5]],@[[0,10],[100,5]],@[[0,10],[100,5]])

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
        plc1.hregs.gets(0,5,hr)
        echo fmt"curren state is {hr}"
        sleep(2000)

main_task()