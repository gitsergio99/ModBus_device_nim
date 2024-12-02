import std/[asyncnet, asyncdispatch,logging,strutils,sequtils,strformat]
import  mbserver
var
    clients {.threadvar.}:seq[AsyncSocket]
    log = newFileLogger("tcp_log.log",fmtStr ="[$time] - $app - $levelname:",lvlAll)
    plc1:ModBus_Device
    resp:string


plc1.modbus_adr=3
plc1.hregs.sets(0,@[int16(10),int16(20),int16(30),int16(40),int16(50),int16(60),int16(70),int16(80),int16(90),int16(100)])

proc prClient(client: AsyncSocket) {.async.} =
    var
        tmp:seq[char] = @[]
        resp:string = ""
        ask:seq[char] = @[]
    while true:
        let line = await client.recv(6)
        tmp = line.toHex.parseHexStr.toSeq()
        let line2 = await client.recv(cast[int](tmp[5]))
        echo line2.toHex.parseHexStr.toSeq()
        ask = tmp
        ask.add(line2.toHex.parseHexStr.toSeq())
        echo fmt"ask adr is {ask[6]} . ASK is {ask}"
        resp = plc1.response(ask)
        echo resp.toHex.parseHexStr.toSeq()
        #log.log(lvlInfo,line.toHex())
        if line.len == 0: break
        await client.send(resp)
        #for c in clients:
        #    await c.send("\c\L")

proc serv () {.async.} =
    clients = @[]
    var server = newAsyncSocket()
    server.setSockOpt(OptReuseAddr, true)
    server.bindAddr(Port(502))
    server.listen()

    while true:
        let client = await server.accept()
        clients.add client
        asyncCheck prClient(client)

asyncCheck serv()
runForever()
        