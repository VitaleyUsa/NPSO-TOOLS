#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\..\..\Games\Fallout Nevada\FoN2.ico
#AutoIt3Wrapper_Res_Comment=Скрипт для настройки ПРКД
#AutoIt3Wrapper_Res_Description=перенос сертификата тех. работника в нужные хранилища
#AutoIt3Wrapper_Res_LegalCopyright=Ситников Виталий
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/SO
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Opt("TrayAutoPause", 0)
Opt("TrayMenuMode", 2)

FileInstall ( "PRKD_func.exe", @TempDir & "\PRKD_func.exe",1)

Run(@TempDir & "\PRKD_func.exe")
Sleep(500)
If WinExists("Ошибка","Сертификат тех. работника не найден") Then
	Exit 0
Else
	$CertInstall = WinWait("Предупреждение системы","Вы хотите установить этот сертификат?",2)
	ControlClick($CertInstall,"","Button1")
	MsgBox("","Настройка ПРКД", "Сертификаты успешно перенесены (но это не точно)",3)
EndIf