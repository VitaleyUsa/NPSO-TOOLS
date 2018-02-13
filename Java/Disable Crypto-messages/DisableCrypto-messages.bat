set FIX="131907744000000000"
set VALUE1="warning_time_gen_2001"
set VALUE2="warning_time_sign_2001"
set KEY32="HKEY_LOCAL_MACHINE\SOFTWARE\Crypto Pro\Cryptography\CurrentVersion\Parameters"
set KEY64="HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Crypto Pro\Cryptography\CurrentVersion\Parameters" 


reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT

:start
if %OS%==32BIT (
  :: 32битная система
  REG ADD %KEY32% /v %VALUE1% /t REG_QWORD /d %FIX% /f
  REG ADD %KEY32% /v %VALUE2% /t REG_QWORD /d %FIX% /f
)

if %OS%==64BIT (
  :: 64битная система
  REG ADD %KEY64% /v %VALUE1% /t REG_QWORD /d %FIX% /f
  REG ADD %KEY64% /v %VALUE2% /t REG_QWORD /d %FIX% /f
)
 
exit /B