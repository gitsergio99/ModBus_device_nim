import std/[tables,sequtils]
import mbregtype
import typetraits
var
    hold_regs = initTable[int,seq[int16]]()
    expl:seq[int16] = newSeq[int16](10)
    dev1:ModBus_Device
    res:bool
    rs: seq[bool]

hold_regs.add(0, newSeq[int16](10))
hold_regs.add(100, newSeq[int16](25))
#initModBus_Device("plc1",true,1,true,initTable[int,seq[int16]]().add(0,newSeq[int16](10)),initTable[int,seq[int16]]().add(0,newSeq[int16](10)),initTable[int,seq[bool]]().add(0,newSeq[bool](10)),initTable[int,seq[bool]]().add(0,newSeq[bool](10)))
initModBus_Device(dev1,"plc1",true,uint8(1),true, @[[0,10],[100,5]], @[[0,10],[100,5]],@[[0,10],[100,5]],@[[0,10],[100,5]])
#echo expl
#echo hold_regs
#echo dev1
res = dev1.hregs.sets(100,@[int16(10),int16(10)])
echo res
for el in dev1.hregs.pairs:
    echo el

#echo dev1.hregs.mvalues.type.name

dev1.coils.gets(120,3,rs)
echo rs