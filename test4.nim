import std/net
let socket = newSocket()
socket.bindAddr(Port(1234))
socket.listen()

# You can then begin accepting connections using the `accept` procedure.
var client: Socket
var address = ""
while true:
  socket.acceptAddr(client, address)
  echo "Client connected from: ", address

   #[   var
        tmp:seq[char] = @[]
        resp:string = ""
        ask:seq[char] = @[]
        bytes_to_get:int
    let socket = newSocket()
    socket.bindAddr(Port(port))
    socket.listen()
    var client: Socket
    var address = ""
    while true:
        client = socket.acceptAddr(client, address)
        let line = client.recv(6)
        tmp = line.toHex.parseHexStr.toSeq()
        bytes_to_get = char_adr_to_int(tmp[4],tmp[5])
        let line2 = client.recv(bytes_to_get)
        echo line2.toHex.parseHexStr.toSeq()
        ask = tmp
        ask.add(line2.toHex.parseHexStr.toSeq())
        echo fmt"ask adr is {ask[6]} . ASK is {ask}"
        resp = plc.response(ask)
        echo resp.toHex.parseHexStr.toSeq()
        #log.log(lvlInfo,line.toHex())
        client.send(resp) ]#