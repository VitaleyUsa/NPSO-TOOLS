:: Sitnikov V.V., NPSO

:: Paths
Set java_security=%APPDATA%\..\LocalLow\Sun\Java\Deployment\security
Set java_warning=%APPDATA%\..\LocalLow\Sun\Java\Deployment\cache\6.0\29

MD "%java_security%" 2>nul 
MD "%java_warning%" 2>nul

:: Trusted + exception

copy /b/v/y trusted.jssecacerts %java_security%\trusted.jssecacerts
copy /b/v/y trusted.certs %java_security%\trusted.certs
copy /b/v/y exception.sites %java_security%\exception.sites

:: Security warning
copy /b/v/y warning.lap %java_warning%\eb53f5d-73e6945133bb0be8a3474bfbe390bf2bb6c48dcd2d42f095274b1a5b089f3985-6.0.lap