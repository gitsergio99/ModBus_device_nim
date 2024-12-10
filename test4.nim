import std/[net,times,strutils]

var name_f:string

name_f.formatValue(now(),"yyyy-MM-dd HH-mm-ss")

echo name_f

proc dt_to_name_file():string =
  let dt = now()
  let year = dt.year
  let mm = dt.month.ord
  let dd = dt.monthday
  let hh = dt.hour
  let mint = dt.minute
  let sec = dt.second
  result = intToStr(year)&'_'&intToStr(mm)&'_'&intToStr(dd)&'_'&intToStr(hh)&'_'&intToStr(mint)&'_'&intToStr(sec)&".log"

echo dt_to_name_file()