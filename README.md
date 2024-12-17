# ModBus_device_nim
Lib for create TCP Modbus device.
## Supported ModBus fucntions: 
<br>                                01 (0x01) Read Coils
<br>                           02 (0x02) Read Discrete Inputs
<br>                           03 (0x03) Read Holding Registers
<br>                           04 (0x04) Read Input Registers
<br>                           05 (0x05) Write Single Coil
<br>                            06 (0x06) Write Single Register
<br>                            15 (0x0F) Write Multiple Coils
<br>                            16 (0x10) Write Multiple registers
<br>                            22 (0x16) Mask Write Register
<br>                            23 (0x17) Read/Write Multiple registers
<br>
## Simple usage can see in test_new.nim:
<br>Create var ModBus_Device type.
<br>Use initModBus_Device for initialization device:
<br>( self: var ModBus_Device, - Modbus device
<br>name:string, - name of device usable for save and restore state of device(state of registers)
<br>log:bool, - logging device true or false
<br>adr:uint8, - Modbus address of device for tcp ordinary use 1
<br>save:bool, - autosave state of device after writing asks - true, false
<br>hr:seq[array[2,int]], - holding registers structure like @[[0,10],[100,5]] - first array in sequence create first piece of registers 0 is start address 10 is quantity and etc.
<br>ir:seq[array[2,int]], - input registers.
<br>co:seq[array[2,int]], - coils
<br>di:seq[array[2,int]] - diskret inputs )

