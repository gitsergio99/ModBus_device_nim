type
    Mb_ram* = ref object of RootObj
        start_address*: uint16
        ram_size*: uint16

    Int_regs* = ref object of Mb_ram
        ram_part*:seq[int16]
    
    Bool_regs* = ref object of Mb_ram
        ram_part*:seq[bool]
    
template sets* [T] (self:T,st_adr:uint16,val:untyped): untyped =
    var
        last_index:uint16 = 0
        start_index:uint16 = 0
        val_len:uint16 = uint16(val.len)
    if (st_adr >= self.start_address) and (st_adr <= self.start_address + self.ram_size-1):
        start_index = st_adr - self.start_address
        if (val_len + start_index - self.start_address) <= self.ram_size:
            last_index = start_index + val_len - 1
            self.ram_part[start_index..last_index] = val

template gets* [T] (self:T,st_adr:uint16,quantity:uint16): untyped =
    var
        start_index:uint16 = 0
        last_index:uint16 = 0
    if (st_adr >= self.start_address) and (st_adr <= self.start_address + self.ram_size-1):
        start_index = st_adr - self.start_address
        if quantity + start_index > self.ram_size - 1:
            last_index = self.ram_size - 1
        else:
            last_index = start_index + quantity-1
    self.ram_part[int(start_index)..int(last_index)]  

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
hregs.sets(uint16(0),@[int16(1),int16(2),int16(3),int16(4),int16(5)])

echo hregs.gets(3,4)
