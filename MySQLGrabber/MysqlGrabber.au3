#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\..\Games\Fallout Nevada\FoN2.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Comment=Нотариальная палата Свердловской области
#AutoIt3Wrapper_Res_Description=Программа для получения данных подключения к mysql
#AutoIt3Wrapper_Res_Fileversion=1.0.0.12
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Ситников Виталий
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/SO
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


Opt("TrayAutoPause", 0)
Opt("TrayMenuMode", 2)
AutoItSetOption("MustDeclareVars", 1)

#include <File.au3>
#include <Array.au3>
#include <Misc.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

Global $en_path = ("C:\Triasoft\eNot")
Global $MySQL_credits[3]

#Region ###
Global $pass_grabber_form = GUICreate("Mysql password grabber", 428, 203, 583, 353)
Global $input_en_path = GUICtrlCreateInput($en_path, 16, 40, 393, 26)
GUICtrlSetFont(-1, 11, 400, 0, "Tahoma")
Global $label_en_path = GUICtrlCreateLabel("Укажите путь до программы Енот", 16, 8, 305, 23)
GUICtrlSetFont(-1, 12, 800, 0, "Tahoma")
Global $label_en_server = GUICtrlCreateLabel("Сервер Mysql:", 16, 80, 98, 20)
GUICtrlSetFont(-1, 10, 800, 0, "Tahoma")
Global $label_en_user = GUICtrlCreateLabel("Имя пользователя:", 16, 104, 134, 20)
GUICtrlSetFont(-1, 10, 800, 0, "Tahoma")
Global $label_en_password = GUICtrlCreateLabel("Пароль:", 16, 128, 59, 20)
GUICtrlSetFont(-1, 10, 800, 0, "Tahoma")
Global $input_en_server = GUICtrlCreateInput("", 128, 80, 281, 21)
GUICtrlSetState(-1, $GUI_DISABLE)
Global $input_en_user = GUICtrlCreateInput("", 160, 104, 249, 21)
GUICtrlSetState(-1, $GUI_DISABLE)
Global $input_en_password = GUICtrlCreateInput("", 88, 128, 321, 21)
GUICtrlSetState(-1, $GUI_DISABLE)
Global $but_get_pass = GUICtrlCreateButton("Получить данные", 310, 160, 100, 25)
GUISetState(@SW_SHOW)
#EndRegion ###

While 1
	Local $nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $but_get_pass
			$MySQL_credits[0] = GUICtrlRead($input_en_server)
			$MySQL_credits[1] = GUICtrlRead($input_en_user)
			$MySQL_credits[2] = GUICtrlRead($input_en_password)

			Local $_EnotStatus = _EnotStart(GUICtrlRead($input_en_path)) ; запускаем енот
			Sleep(1500) ; ждем 1.5 секунды после запуска
			_GetPass($_EnotStatus)  ; получаем данные mysql
			ControlSetText($pass_grabber_form,"",$input_en_server,$MySQL_credits[0])
			ControlSetText($pass_grabber_form,"",$input_en_user,$MySQL_credits[1])
			ControlSetText($pass_grabber_form,"",$input_en_password,$MySQL_credits[2])
	EndSwitch
WEnd

Func _EnotStart($path) ; Запуск енота
	If Not ProcessExists("eNot.exe") Then ; Проверяем, запущен ли Енот
		If FileExists ($path) Then ; Ищем путь к программе
			Run($path & "\enot.exe") ; Запускаем енот
			WinWait ("[CLASS:ThunderRT6MDIForm]","",450)
			Return("NotLoaded")
		Else
			MsgBox("","Программа не найдена","Укажите верный путь к папке с енотом") ; Если путь к программе не найден
			Return("WrongPath")
		EndIf
	Else
		Return("Loaded")
	EndIf
EndFunc ; _EnotStart

Func _GetPass ($en_status) ; Получение данные об Mysql сервере
	If $en_status <> "WrongPath" Then  ; если загрузили енот, то
		If WinExists ("[CLASS:ThunderRT6MDIForm]","") Then
			Local $en_handle = WinWait("[CLASS:ThunderRT6MDIForm]","",5)
			If Not WinExists("Настройки eNot","") Then WinMenuSelectItem($en_handle,"","&Программа","Настройка")
			Local $en_set = WinWait("Настройки eNot")
			Local $en_serv = ControlGetText($en_set, '', '[CLASS:ThunderRT6TextBox; INSTANCE:16]')
			Local $en_user = ControlGetText($en_set, '', '[CLASS:ThunderRT6TextBox; INSTANCE:14]')
			Local $en_pass = ControlGetText($en_set, '', '[CLASS:ThunderRT6TextBox; INSTANCE:13]')

			$MySQL_credits[0] = $en_serv
			$MySQL_credits[1] = $en_user
			$MySQL_credits[2] = $en_pass
			; Закрываем настройки и енот
			ControlClick($en_set,"",'[CLASS:ThunderRT6CommandButton; INSTANCE:1]')
			If $en_status == "NotLoaded" Then ; закроем енот, если ранее не был открыт
				WinClose($en_handle)
				If WinExists("eNot","Run-time") Then WinClose("eNot","Run-time")
			EndIf
			ClipPut($en_pass)
			TrayTip ( "", "Пароль скопирован в буфер обмена",5)
		EndIf
	EndIf
EndFunc ; _GetPass
