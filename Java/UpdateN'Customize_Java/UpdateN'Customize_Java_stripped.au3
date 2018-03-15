#RequireAdmin
FileInstall("wget.exe","wget.exe",1)
FileInstall("JavaSettings.exe","JavaSettings.exe",1)
Opt("TrayAutoPause", 0)
Opt("TrayMenuMode", 2)
Global Const $tagRECT = "struct;long Left;long Top;long Right;long Bottom;endstruct"
Global Const $tagREBARBANDINFO = "uint cbSize;uint fMask;uint fStyle;dword clrFore;dword clrBack;ptr lpText;uint cch;" & "int iImage;hwnd hwndChild;uint cxMinChild;uint cyMinChild;uint cx;handle hbmBack;uint wID;uint cyChild;uint cyMaxChild;" & "uint cyIntegral;uint cxIdeal;lparam lParam;uint cxHeader" &((@OSVersion = "WIN_XP") ? "" : ";" & $tagRECT & ";uint uChevronState")
Global Const $HGDI_ERROR = Ptr(-1)
Global Const $INVALID_HANDLE_VALUE = Ptr(-1)
Global Const $KF_EXTENDED = 0x0100
Global Const $KF_ALTDOWN = 0x2000
Global Const $KF_UP = 0x8000
Global Const $LLKHF_EXTENDED = BitShift($KF_EXTENDED, 8)
Global Const $LLKHF_ALTDOWN = BitShift($KF_ALTDOWN, 8)
Global Const $LLKHF_UP = BitShift($KF_UP, 8)
Global Const $tagOSVERSIONINFO = 'struct;dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128];endstruct'
Global Const $__WINVER = __WINVER()
Func __WINVER()
Local $tOSVI = DllStructCreate($tagOSVERSIONINFO)
DllStructSetData($tOSVI, 1, DllStructGetSize($tOSVI))
Local $aRet = DllCall('kernel32.dll', 'bool', 'GetVersionExW', 'struct*', $tOSVI)
If @error Or Not $aRet[0] Then Return SetError(@error, @extended, 0)
Return BitOR(BitShift(DllStructGetData($tOSVI, 2), -8), DllStructGetData($tOSVI, 3))
EndFunc
Global Const $INET_FORCERELOAD = 1
Func _INetGetSource($sURL, $bString = True)
Local $sString = InetRead($sURL, $INET_FORCERELOAD)
Local $iError = @error, $iExtended = @extended
If $bString = Default Or $bString Then $sString = BinaryToString($sString)
Return SetError($iError, $iExtended, $sString)
EndFunc
Local $_JavaURL = "https://java.com/ru/download/manual.jsp"
Local $_Args = "/s REMOVEOUTOFDATEJRES=1"
$oIE = _INetGetSource($_JavaURL)
$_tmpLink = _StringBetween2($oIE, 'http://javadl.oracle.com', '"')
$_Link = '"' & "http://javadl.oracle.com" & $_tmpLink & '"'
SplashTextOn("Статус", "Скачиваем JAVA", 550, 130, -1, -1, 33, "",10)
RunWait("wget.exe -O Java.exe -c --tries=0 --read-timeout=5 --no-check-certificate -c --header " & "Cookie: oraclelicense=accept-securebackup-cookie " & $_Link)
ControlSetText("Статус", '', 'Static1', "Производится обновление JAVA")
RunWait("Java.exe " & $_Args)
ControlSetText("Статус", '', 'Static1', "Производится настройка JAVA")
sleep(1000)
RunWait("JavaSettings.exe")
ControlSetText("Статус", '', 'Static1', "Обновление завершено. Программа автоматически закроется через 5 секунд")
Sleep(5000)
Func _StringBetween2($s, $from, $to)
$x = StringInStr($s, $from) + StringLen($from)
$y = StringInStr(StringTrimLeft($s, $x), $to)
Return StringMid($s, $x, $y)
EndFunc
