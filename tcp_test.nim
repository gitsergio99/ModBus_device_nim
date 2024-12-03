import std/[asyncnet, asyncdispatch,logging,strutils,sequtils,strformat]
import  mbserver
var
    clients {.threadvar.}:seq[AsyncSocket]
    log = newFileLogger("tcp_log.log",fmtStr ="[$time] - $app - $levelname:",lvlAll)
    plc1:ModBus_Device
    resp:string


plc1.modbus_adr=3
plc1.hregs.sets(0,@[int16(10),int16(20),int16(30),int16(40),int16(50),int16(60),int16(70),int16(80),int16(90),int16(100)])
plc1.iregs.sets(0,@[int16(15),int16(25),int16(35),int16(45),int16(55),int16(65),int16(75),int16(85),int16(95),int16(105)])
plc1.coils.sets(0,@[true,false,true,false,true,false,true,false,true,false])
plc1.di.sets(0,@[true,true,true,false,false,true,true,true,true,true,true,true,true])

proc prClient(client: AsyncSocket) {.async.} =
    var
        tmp:seq[char] = @[]
        resp:string = ""
        ask:seq[char] = @[]
        bytes_to_get:int
    while true:
        let line = await client.recv(6)
        tmp = line.toHex.parseHexStr.toSeq()
        bytes_to_get = char_adr_to_int(tmp[4],tmp[5])
        let line2 = await client.recv(bytes_to_get)
        echo line2.toHex.parseHexStr.toSeq()
        ask = tmp
        ask.add(line2.toHex.parseHexStr.toSeq())
        echo fmt"ask adr is {ask[6]} . ASK is {ask}"
        resp = plc1.response(ask)
        echo resp.toHex.parseHexStr.toSeq()
        #log.log(lvlInfo,line.toHex())
        if line.len == 0: break
        await client.send(resp)
proc serv () {.async.} =
    #clients = @[]
    var server = newAsyncSocket()
    server.setSockOpt(OptReuseAddr, true)
    server.bindAddr(Port(502))
    server.listen()

    while true:
        let client = await server.accept()
        #clients.add client
        asyncCheck prClient(client)


asyncCheck serv()
runForever()
        