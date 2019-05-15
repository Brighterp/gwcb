
@ECHO OFF
cls
Echo compiling forms 12c ..Please Wait.Bright Information Systems.
for %%f IN (*.fmb) do D:\Oracle\Middleware\Oracle_Home\bin\frmcmp.exe userid=BRIGHT/BRIGHT@ORCL  module=%%f batch=NO module_type=form compile_all=yes window_state=minimize 
ECHO form compilation complete

@ECHO OFF
cls
Echo compiling Library 12c ..Please Wait.Bright Information Systems.
for %%f IN (*.pll) do D:\Oracle\Middleware\Oracle_Home\bin\frmcmp.exe userid=BRIGHT/BRIGHT@ORCL  module=%%f batch=NO module_type=library compile_all=yes window_state=minimize 
ECHO form compilation complete

@ECHO OFF
cls
Echo compiling menu 12c ..Please Wait.Bright Information Systems.
for %%f IN (*.mmb) do D:\Oracle\Middleware\Oracle_Home\bin\frmcmp.exe userid=BRIGHT/BRIGHT@ORCL  module=%%f batch=NO module_type=menu compile_all=yes window_state=minimize 
ECHO form compilation complete