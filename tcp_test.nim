import std/[asyncnet, asyncdispatch,logging,strutils,sequtils]
import  mbserver

var
    clients {.threadvar.}:seq[AsyncSocket]
    log = newFileLogger("tcp_log.log",fmtStr ="[$time] - $app - $levelname:",lvlAll)
    plc1:ModBus_Device


plc1.modbus_adr=3

proc prClient(client: AsyncSocket) {.async.} =
    var
        tmp:seq[char] = @[]
        resp:string = ""
    while true:
        let line = await client.recv(6)
        #tmp = line.toHex.parseHexStr.toSeq() 
        #let line_end = await client.recv(cast[int](tmp[4]))
        #tmp.add(line_end.toHex.parseHexStr.toSeq())
        #resp = plc1.response(tmp)
        tmp = line.toHex.parseHexStr.toSeq()
        echo tmp
        echo cast[int](tmp[5])
        let line2 = await client.recv(cast[int](tmp[5]))
        echo line2.toHex.parseHexStr.toSeq()
        log.log(lvlInfo,line.toHex())
        if line.len == 0: break
        await client.send("\c\L")
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
        