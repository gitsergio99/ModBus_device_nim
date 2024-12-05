import modbusutil
import std/[sequtils,strutils,strformat,bitops]
#import asyncdispatch

type
    ModBus_Device* = object
        modbus_adr:uint8 = 1
        hregs*:array[0..65535,int16]
        iregs*:array[0..65535,int16]
        coils*:array[0..65535,bool]
        di*:array[0..65535,bool]

#set and get procs for regs memory
template sets* [T] (regs:T,adr:int,val:untyped): untyped =
    for i in 0..val.len-1:
        regs[adr+i] = val[i]

template gets* [T] (regs:T,adr:int,quantity:int): untyped =
    regs[adr..adr+quantity-1]

# setter and getter of modbus device address
proc `modbus_adr=`*(self: var ModBus_Device,adr:uint8) =
    self.modbus_adr = adr

proc `modbus_adr`*(self:ModBus_Device):uint8 =
    self.modbus_adr

# setter and getter rtu mode of modbus device
proc `rtu=`*(self: var ModBus_Device,s:bool) =
    self.rtu = s

proc `rtu`*(self:ModBus_Device):bool =
    self.rtu

# modbus error message for tcp transport
proc tcp_error_response(mbap:seq[char],adr:char,fn:char,err:char): string =
    var
        temp_resp:seq[char] = @[]
        res:string
    temp_resp.add(mbap)
    temp_resp.add('\x03')
    temp_resp.add(adr)
    temp_resp.add(cast_c(cast[uint8](fn)+128))
    temp_resp.add(err)
    apply(temp_resp,proc(it:char) = res.add(it))
    return res

# two char to int
proc char_adr_to_int*(c1:char,c2:char): int =
    var
        temp_str:string =""
    temp_str.add(c1)
    temp_str.add(c2)
    #temp_str.toHex.fromHex[:uint16]
    return int(temp_str.toHex.fromHex[:uint16])

proc chars_val_to_int16*(ch:seq[char]): seq[int16] =
    var
        res:seq[int16] = @[]
        temp_str:string = ""
    for i in 0..int(ch.len/2-1):
        temp_str.add(ch[i*2])
        temp_str.add(ch[i*2+1])
        res.add(temp_str.toHex.fromHex[:int16])
        temp_str =""
    return res

# check what address in modbus device allowed 
proc check_reg_access(self:ModBus_Device,reg:int,q:int,region:int): bool =
    return true

# sequance of int16 to sequance of chars
proc seq_int16_to_seq_chr*(i:seq[int16]):seq[char] =
    var out_seq:seq[char] = @[]
    for x in i:
        out_seq.add(x.toHex.parseHexStr.toSeq())
    return out_seq

#if our device have tcp transport
proc response*(self: var ModBus_Device, ask_data:seq[char]): string =
    var
        supported_fn:array[0..9,char] = ['\x01','\x02','\x03','\x04','\x05','\x06','\x0F','\x10','\x16','\x17']
        mbap_strater:seq[char] = ask_data[0..4]
        tmp_adr:char = ask_data[6]
        tmp_fn:char = ask_data[7]
        outer_str:string
        outer_seq:seq[char] = @[]
        reg_adr:int = 0
        quan:int = 0
    if tmp_adr == cast_c(self.modbus_adr):
        if tmp_fn in supported_fn:
            reg_adr = char_adr_to_int(ask_data[8],ask_data[9])
            quan = char_adr_to_int(ask_data[10],ask_data[11])
            outer_seq.add(ask_data[0..3])
            case tmp_fn
            of '\x03': #read holding registers from modbus device
                let h_regs_g:seq[int16] = self.hregs.gets(reg_adr,quan)
                let byte_count:uint8 = uint8(quan)*2
                let tcp_bytes:uint16 = uint16(quan)*2 + 3                 
                outer_seq.add(cast_u16(tcp_bytes))
                outer_seq.add(tmp_adr)
                outer_seq.add(tmp_fn)
                outer_seq.add(cast_c(byte_count))
                outer_seq.add(seq_int16_to_seq_chr(h_regs_g))
                apply(outer_seq, proc(c:char) = outer_str.add(c))
            of '\x04': #read input registers from modbus device
                let iregs_g:seq[int16] = self.iregs.gets(reg_adr,quan)
                let byte_count:uint8 = uint8(quan)*2
                let tcp_bytes:uint16 = uint16(quan)*2 + 3
                outer_seq.add(cast_u16(tcp_bytes))
                outer_seq.add(tmp_adr)
                outer_seq.add(tmp_fn)
                outer_seq.add(cast_c(byte_count))
                outer_seq.add(seq_int16_to_seq_chr(iregs_g))
                apply(outer_seq, proc(c:char) = outer_str.add(c))
            of '\x01': #read coils from modbus device
                let coils_g:seq[bool] = self.coils.gets(reg_adr,quan)
                let bytes_of_coils:seq[char] = bools_pack_to_bytes(coils_g)
                let byte_count:uint8 = uint8(bytes_of_coils.len)
                let tcp_bytes:uint16 = uint16(byte_count) + 3
                outer_seq.add(cast_u16(tcp_bytes))
                outer_seq.add(tmp_adr)
                outer_seq.add(tmp_fn)
                outer_seq.add(cast_c(byte_count))
                outer_seq.add(bytes_of_coils)
                apply(outer_seq, proc(c:char) = outer_str.add(c))
            of '\x02': #read discret inputs from modbus device
                let di_g:seq[bool] = self.di.gets(reg_adr,quan)
                let bytes_of_di:seq[char] = bools_pack_to_bytes(di_g)
                let byte_count:uint8 = uint8(bytes_of_di.len)
                let tcp_bytes:uint16 = uint16(byte_count) + 3
                outer_seq.add(cast_u16(tcp_bytes))
                outer_seq.add(tmp_adr)
                outer_seq.add(tmp_fn)
                outer_seq.add(cast_c(byte_count))
                outer_seq.add(bytes_of_di)
                apply(outer_seq, proc(c:char) = outer_str.add(c))
            of '\x05': # set coil in modbus device
                if quan == 0 or quan == 65280:
                    self.coils.sets(reg_adr,@[quan != 0])
                    outer_seq = ask_data
                    apply(outer_seq, proc(c:char) = outer_str.add(c))
                else:
                    outer_str = tcp_error_response(mbap_strater,tmp_adr,tmp_fn,'\x03')
            of '\x06': # write to holding register in modbus device
                self.hregs.sets(reg_adr,chars_val_to_int16(ask_data[10..11]))
                outer_seq = ask_data
                apply(outer_seq, proc(c:char) = outer_str.add(c))
            of '\x0F': # write to coils in modbus device
                let last_el:int = 12 + int(cast[uint8](ask_data[12]))
                self.coils.sets(reg_adr,bytes_to_seq_of_bools(ask_data[13..last_el],quan))
                outer_seq = ask_data[0..11]
                apply(outer_seq, proc(c:char) = outer_str.add(c))
            of  '\x10': # write to holding registers in modbus device
                let last_el:int = 12 + int(cast[uint8](ask_data[12]))
                self.hregs.sets(reg_adr,chars_val_to_int16(ask_data[13..last_el]))
                outer_seq = ask_data[0..11]
                apply(outer_seq, proc(c:char) = outer_str.add(c))
            of  '\x17': # read/write holding registers in modbus device
                let h_regs_g:seq[int16] = self.hregs.gets(reg_adr,quan)
                let byte_count:uint8 = uint8(quan)*2
                let tcp_bytes:uint16 = uint16(quan)*2 + 3                 
                outer_seq.add(cast_u16(tcp_bytes))
                outer_seq.add(tmp_adr)
                outer_seq.add(tmp_fn)
                outer_seq.add(cast_c(byte_count))
                outer_seq.add(seq_int16_to_seq_chr(h_regs_g))
                apply(outer_seq, proc(c:char) = outer_str.add(c))
                let last_el:int = 16 + int(cast[uint8](ask_data[16]))
                self.hregs.sets(reg_adr,chars_val_to_int16(ask_data[17..last_el]))
            of '\x16': # write mask holding registers in modbus device
                let h_r:int16 = self.hregs.gets(reg_adr,1)[0]
                let and_mask:int16 = chars_val_to_int16(ask_data[10..11])[0]
                let or_mask:int16 = chars_val_to_int16(ask_data[12..13])[0]
                #let masked_reg:int16 = bitor(bitand(h_r,and_mask),bitand(or_mask,not and_mask))
                self.hregs.sets(reg_adr,@[bitor(bitand(h_r,and_mask),bitand(or_mask,not and_mask))])
                outer_seq = ask_data
                apply(outer_seq, proc(c:char) = outer_str.add(c))
            else:
                outer_str = ""
        else:
            outer_str = tcp_error_response(mbap_strater,tmp_adr,tmp_fn,'\x01')
    else:
        outer_str = ""
    
    return outer_str

    


    
