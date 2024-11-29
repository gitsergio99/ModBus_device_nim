import std/[asyncnet, asyncdispatch,logging,strutils,sequtils]

var
    clients {.threadvar.}:seq[AsyncSocket]
    log = newFileLogger("tcp_log.log",fmtStr ="[$time] - $app - $levelname:",lvlAll)



proc prClient(client: AsyncSocket) {.async.} =
    while true:
        let line = await client.recvLine()
        echo line.toHex.parseHexStr.toSeq()
        log.log(lvlInfo,line.toHex())
        if line.len == 0: break
        for c in clients:
            await c.send(line & "\c\L")

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
        