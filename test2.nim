import std/[bitops,strutils]
var
    content:int16 = 0x0012
    and_mask:int16 = 0x00F2
    or_mask:int16 = 0x0025
    res:int16 = 0
    not_and_mask:int16 = not and_mask
res = bitor(bitand(content,and_mask),bitand(or_mask,not_and_mask))
echo res.toHex