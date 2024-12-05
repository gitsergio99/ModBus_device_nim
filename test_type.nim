type
    Mb_ram* = ref object of RootObj
        start_address*: uint16
        ram_size*: uint16

    Int_regs* = ref object of Mb_ram
        ram_part*:seq[int16]
    
    Bool_regs* = ref object of Mb_ram
        ram_part*:seq[bool]
    
template sets* [T] (self:T,val:untyped): untyped =
    var
        last_index:int = 0
    if self.ram_size < val.len:
        last_index = int(self.ram_size - 1)
        echo "out of index"
    else:
        last_index = val.len - 1
    for i in 0..last_index:
        self.ram_part[i] = val[i]

template gets* [T] (self:T,quantity:int): untyped =
    var
        last_index:int = 0
    if self.ram_size < quantity:
        last_index = int(self.ram_size - 1)
    else:
        last_index = quantity - 1
    self.ram_part[0..last_index]
        
proc `start_address=`(self:Mb_ram,st_ad:uint16) =
    self.start_address  = st_ad
    
proc `ram_size=`(self:Mb_ram,size:uint16) =
    self.ram_size  = size

proc `start_address`(self:Mb_ram):uint16 =
    self.start_address
    
proc `ram_size=`(self:Mb_ram):uint16 =
    self.ram_size

proc initInt_regs(st:int,sz:int): Int_regs = Int_regs(start_address:uint16(st),ram_size:uint16(sz),ram_part: newSeq[int16](sz))
proc initBool_regs(st:int,sz:int): Bool_regs = Bool_regs(start_address:uint16(st),ram_size:uint16(sz),ram_part: newSeq[bool](sz))    

var
    hregs:Int_regs

hregs = initInt_regs(0,5)
#hregs.sets(@[int16(0),int16(1),int16(2),int16(3),int16(4)])

echo hregs.gets(8)
