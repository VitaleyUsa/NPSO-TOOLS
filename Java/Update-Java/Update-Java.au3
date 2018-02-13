#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\..\Games\Fallout Nevada\FoN2.ico
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Comment=Java updater
#AutoIt3Wrapper_Res_Description=NPSO
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=Sitnikov V.V.
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
FileInstall("wget.exe","wget.exe",0)
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Opt("TrayAutoPause", 0)
Opt("TrayMenuMode", 2)

#include <IE.au3>
#include "Array.au3"
#include <Inet.au3>

; Ситников В.В. НПСО

Local $_JavaURL = "https://java.com/ru/download/manual.jsp"
Local $_Args = "/s REMOVEOUTOFDATEJRES=1"

$oIE = _INetGetSource($_JavaURL)
$_tmpLink = _StringBetween2($oIE, "Offline"" href=", ">")


SplashTextOn("Статус", "Скачиваем JAVA", 550, 130, -1, -1, 33, "",10)
RunWait("wget.exe -O Java.exe -c --tries=0 --read-timeout=5 --no-check-certificate -c --header " & "Cookie: oraclelicense=accept-securebackup-cookie " & "http://javadl.oracle.com/webapps/download/AutoDL?BundleId=227550_e758a0de34e24606bca991d704f6dcbf")
ControlSetText("Статус", '', 'Static1', "Производится обновление JAVA, пожалуйста подождите")
RunWait("Java.exe " & $_Args)
ControlSetText("Статус", '', 'Static1', "Обновление завершено. Программа автоматически закроется через 5 секунд")
Sleep(5000)



Func _StringBetween2($s, $from, $to)
    $x = StringInStr($s, $from) + StringLen($from)
    $y = StringInStr(StringTrimLeft($s, $x), $to)
    Return StringMid($s, $x, $y)
EndFunc  ;==>_StringBetween