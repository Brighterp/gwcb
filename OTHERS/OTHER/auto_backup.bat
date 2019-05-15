set today=%date:~7,2%%date:~4,2%%date:~-4%
D:\oracle\db10g\bin\exp ATC_BRIGHT/ATC_BRIGHT@10GE file=d:\bright\DMP\ATC_BRIGHT_%today%.dmp log=d:\bright\DMP\ATC_BRIGHT_%today%.log
