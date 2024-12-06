import taskpools
import std/[random,strformat,os]

var
    shared_var:int = 0

randomize()

proc random_task(n:int) =
    
    while true:
        shared_var = rand(n)
        echo fmt"second task {shared_var}"
        sleep(1000)

proc main_task() =
    var
        #ntreads = countProcessors()
        tp = Taskpool.new(num_threads = 4)
    spawn(tp,random_task(100))
    while true:
        echo fmt"main loop {shared_var}"
        sleep(2000)

main_task()