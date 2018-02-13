#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\..\Games\Fallout Nevada\FoN2.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Res_Comment=Нотариальная палата Свердловской области
#AutoIt3Wrapper_Res_Description=Автоматическая установка NetFramework 4.7.1
#AutoIt3Wrapper_Res_Fileversion=1.0.0.5
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Ситников Виталий
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=highestAvailable
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/SO
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#pragma compile(UPX, False)

#include <File.au3>
#include <GUIConstantsEx.au3>
#include <Misc.au3>

Global $Tools = @ScriptDir & '\Tools\'
Global $Temp = @ScriptDir & '\Temp\'
Global $FnsLink = IniRead ($Tools & "fns.ini","ФНС","Ссылка","")
Global $msiErr = ""

_Main()


Func _Main()
	If DirGetSize("Temp") == -1 Then DirCreate("Temp")

	If _CheckDotNet4() Then
		_CheckWindows()

		RunWait($Tools & "wget.exe -c --tries=0 --read-timeout=5 https://download.microsoft.com/download/9/E/6/9E63300C-0941-4B45-A0EC-0008F96DD480/NDP471-KB4033342-x86-x64-AllOS-ENU.exe -P Temp")
		RunWait($Temp & 'NDP471-KB4033342-x86-x64-AllOS-ENU.exe /passive /norestart')
	EndIf

	_PPDGR()

EndFunc

Func _CheckDotNet4() ; Устанавливаем netframework 4, если не установлен
    Local $s = RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full', 'Release')
	If $s < 460805 Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>_CheckDotNet4

Func _CheckWindows() ; Патч для Windows7
	Local $status_bits, $status_updates
	If @OSVersion = "Win_7" Then
		If _Hotfix("4019990") == "0" Then
			; Проверяем, что включены службы обновления винды
			If _RetrieveServiceState("bits") <> "Running" Then	; Включаем службу обновления bits
				$status_bits = "1"
				RunWait(@ComSpec & ' /c sc config bits start=demand', '', @SW_HIDE)
				RunWait(@ComSpec & ' /c net start bits', '', @SW_HIDE)
			EndIf
			If _RetrieveServiceState("wuauserv") <> "Running" Then	; Включаем службу обновления windows
				$status_updates = "1"
				RunWait(@ComSpec & ' /c sc config wuauserv start=demand', '', @SW_HIDE)
				RunWait(@ComSpec & ' /c net start wuauserv', '', @SW_HIDE)
			EndIf

			; Проверяем разрядность оси
			If @OSArch = "X86" Then
				RunWait($Tools & "wget.exe -c --tries=0 --read-timeout=5 http://download.microsoft.com/download/2/F/4/2F4F48F4-D980-43AA-906A-8FFF40BCB832/Windows6.1-KB4019990-x86.msu -P Temp")
				RunWait($Temp & "Windows6.1-KB4019990-x86.msu /passive /norestart")
			Else
				RunWait($Tools & "wget.exe -c --tries=0 --read-timeout=5 http://download.microsoft.com/download/2/F/4/2F4F48F4-D980-43AA-906A-8FFF40BCB832/Windows6.1-KB4019990-x64.msu -P Temp")
				RunWait($Temp & "Windows6.1-KB4019990-x64.msu /passive /norestart")
			EndIf

			; Выключаем включенные службы обновления винды
			If $status_bits Then	; Выключаем службу обновления bits
				$status_bits = "0"
				RunWait(@ComSpec & ' /c sc config bits start=disabled', '', @SW_HIDE)
				RunWait(@ComSpec & ' /c net stop bits', '', @SW_HIDE)
			EndIf
			If $status_updates Then	; Выключаем службу обновления windows
				$status_updates = "0"
				RunWait(@ComSpec & ' /c sc config wuauserv start=disabled', '', @SW_HIDE)
				RunWait(@ComSpec & ' /c net stop wuauserv', '', @SW_HIDE)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_CheckWindows

Func _PPDGR()
 	Local $dir = @ScriptDir

	If Not FileExists($Temp & "Setup_PPDGR.msi") Then RunWait($Tools & "wget.exe -c --tries=0 --read-timeout=5  " & $FnsLink & " -P Temp") ; Загрузка ППДГР

	RunWait($Tools & "UnRAR.exe e -y  Temp\Setup_PPDGR_full.exe Temp\") ; Распаковываем ППДГР
	FileChangeDir($Temp)
		$msiErr = RunWait('msiexec /fa Setup_PPDGR.msi /passive /norestart REBOOT=ReallySuppress') ; Устанавливаем ППДГР (даже если уже установлен)
		if $msiErr == "1605" Then RunWait("msiexec /i Setup_PPDGR.msi /passive /norestart REBOOT=ReallySuppress")
		$msiErr = ""
	FileChangeDir($dir)


	$BPrint = WinWait("Печать НД","",5) ; Установка модуля печати
	if WinExists($BPrint) Then
		Local $PidActwin = WinGetProcess($BPrint)
		ProcessClose($PidActwin)

		If @OSArch = "X64" Then
			FileChangeDir("C:\Program Files (x86)\АО ГНИВЦ\ППДГР")
		Else
			FileChangeDir("C:\Program Files\АО ГНИВЦ\ППДГР")
		EndIf

			Local $hSearch = FileFindFirstFile("*.msi")
			$sFileName = FileFindNextFile($hSearch)
			FileClose($hSearch)
			FileCopy(@WorkingDir & "\" & $sFileName,$Temp & "BPrint.msi")

			FileChangeDir($Temp)
			$msiErr = RunWait("msiexec /fa BPrint.msi /passive /norestart REBOOT=ReallySuppress")
			if $msiErr == "1605" Then RunWait("msiexec /i BPrint.msi /passive /norestart REBOOT=ReallySuppress")
			$msiErr = ""

			FileChangeDir($dir)
	EndIf

EndFunc   ;==>_PPDGR

Func _Hotfix($hotfix_name)
	Local $iRET = RunWait(@ComSpec & ' /c WMIC qfe get hotfixid | FIND "' & $hotfix_name & '"', @TempDir, @SW_HIDE)
	If $iRET Then
		Return("0")
	Else
		Return("1")
	EndIf
EndFunc   ;==>_Hotfix

Func _RetrieveServiceState($s_ServiceName) ; получение статуса службы
    Local Const $wbemFlagReturnImmediately = 0x10
    Local Const $wbemFlagForwardOnly = 0x20
	Local $s_Machine = @ComputerName
    Local $colItems = "", $objItem
    Local $objWMIService = ObjGet("winmgmts:\\" & $s_Machine & "\root\CIMV2")
    If @error Then
        MsgBox(16, "_RetrieveServiceState", "ObjGet Error: winmgmts")
        Return
    EndIf
    $colItems = $objWMIService.ExecQuery ("SELECT * FROM Win32_Service WHERE Name = '" & $s_ServiceName & "'", "WQL", _
            $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
    If @error Then
        MsgBox(16, "_RetrieveServiceState", "ExecQuery Error: SELECT * FROM Win32_Service")
        Return
    EndIf
    If IsObj($colItems) Then
        For $objItem In $colItems
            Return $objItem.State
        Next
    EndIf
EndFunc   ;==>_RetrieveServiceState
