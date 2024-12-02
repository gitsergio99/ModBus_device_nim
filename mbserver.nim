import modbusutil
import std/[sequtils,strutils]
#import asyncdispatch


type
    ModBus_Device* = object
        modbus_adr:uint8 = 1
        hregs*:array[0..65535,int16]
        iregs*:array[0..65535,int16]
        coils*:array[0..65535,bool]
        di*:array[0..65535,bool]
        rtu:bool = false
        #allowed regions of holding registers: default all 65536 registers allowed
        # [start_address,quantity]
        allowed_hregs:seq[array[0..1,int]] = @[[0,65536]] 
        allowing_hregs:bool = false # if false allowed_hregs no matter
        allowed_iregs:seq[array[0..1,int]] = @[[0,65536]] 
        allowing_iregs:bool = false # if false allowed_iregs no matter
        allowed_coils:seq[array[0..1,int]] = @[[0,65536]] 
        allowing_coils:bool = false # if false allowed_coils no matter
        allowed_di:seq[array[0..1,int]] = @[[0,65536]] 
        allowing_di:bool = false # if false allowed_di no matter
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


proc char_adr_to_int*(c1:char,c2:char): int =
    var
        temp_str:string =""
    temp_str.add(c1)
    temp_str.add(c2)
    #temp_str.toHex.fromHex[:uint16]
    return int(temp_str.toHex.fromHex[:uint16])

proc check_reg_access(self:ModBus_Device,reg:int,q:int): bool =
    return true


proc seq_int16_to_seq_chr*(i:seq[int16]):seq[char] =
    var out_seq:seq[char] = @[]
    for x in i:
        out_seq.add(x.toHex.parseHexStr.toSeq())
    return out_seq

#if our device have tcp transport
proc response_tcp(self:ModBus_Device,ask_data:seq[char]): string =
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
            case tmp_fn
            of '\x03':
                reg_adr = char_adr_to_int(ask_data[8],ask_data[9])
                quan = char_adr_to_int(ask_data[10],ask_data[11])
                if check_reg_access(self,reg_adr,quan):
                    let h_regs_g:seq[int16] = self.hregs.gets(reg_adr,quan)
                    let byte_count:uint8 = uint8(quan)*2
                    let tcp_bytes:uint16 = uint16(quan)*2 + 3
                    outer_seq.add(ask_data[0..3])
                    outer_seq.add(cast_u16(tcp_bytes))
                    outer_seq.add(tmp_adr)
                    outer_seq.add(tmp_fn)
                    outer_seq.add(cast_c(byte_count))
                    outer_seq.add(seq_int16_to_seq_chr(h_regs_g))
                apply(outer_seq, proc(c:char) = outer_str.add(c))
            else:
                outer_str = ""
        else:
            outer_str = tcp_error_response(mbap_strater,tmp_adr,tmp_fn,'\x01')
            #outer_seq.add(mbap_strater)
            #outer_seq.add('\x03')
            #outer_seq.add(tmp_adr)
            #outer_seq.add(cast_c(cast[uint8](tmp_fn)+128))
            #outer_seq.add('\x01')
            #apply(outer_seq,proc(it:char) = outer_str.add(it))
    else:
        outer_str = "\c\L"
    
    return outer_str

proc response_rtu(self:ModBus_Device,ask_data:seq[char]): string =
    var
        outer_str:string =""
    return outer_str


method response*(self:ModBus_Device,ask_data:seq[char]): string =
    if self.rtu == false:
        return response_tcp(self,ask_data)
    else:
        return response_rtu(self,ask_data)
    


    
