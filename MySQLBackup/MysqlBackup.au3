#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\..\Games\Fallout Nevada\FoN2.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Comment=Нотариальная палата Свердловской области
#AutoIt3Wrapper_Res_Description=Программа для резервного копирования БД Енот
#AutoIt3Wrapper_Res_Fileversion=1.0.0.6
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_LegalCopyright=Ситников Виталий
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=highestAvailable
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/SO
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#pragma compile(UPX, False)

Opt("TrayAutoPause", 0)
Opt("TrayMenuMode", 2)
AutoItSetOption("MustDeclareVars", 1)
FileInstall("mysqldump.exe", @TempDir & "\mysqldump.exe", 0)
FileInstall("mysql.exe", @TempDir & "\mysql.exe", 0)

#include <File.au3>
#include <Array.au3>
#include <Misc.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <StringEncrypt.au3>

Global $sPass = "08CA98798C0D37A0F0878F15D822BD7074DB833A883F1FC7D60BF13736742ECC50147A995B65A93217A6941FA48C775C72BD5E0A277A51C13D51D2F7715A60C838128EA8F2604A7D4D8FE80E7F54955E2865C19CCBEC511DA032AF091F8A91513A879ED1B460FCA1F716560A431C04E4AAD6402194B567677EE39740835A022A"
Global $en_path = ("C:\Triasoft\eNot")
Global $backup_path = ("C:\Distr\Mysql-backup")
Local $import_directory
Global $MySQL_credits[4]
Global $en_status

Global $width = 319
Global $height = 126

_Password()
#Region GUI ###
Global $MysqlBackup_form = GUICreate("Mysql backup and restore", 498, 403, @DesktopWidth / 2 - $width / 1.5, @DesktopHeight / 2.5 - $height)
GUICtrlSetFont(-1, 14, 400, 0, "Arial")
Global $label_caption = GUICtrlCreateLabel("Резервное копирование баз данных ЕИС", 32, 32, 367, 26)
GUICtrlSetFont(-1, 16, 800, 0, "Arial Narrow")
Global $input_en_path = GUICtrlCreateInput($en_path, 32, 104, 425, 24)
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
Global $label_en_path = GUICtrlCreateLabel("Укажите путь до программы 'Енот'", 32, 80, 196, 20)
GUICtrlSetFont(-1, 10, 800, 0, "Arial Narrow")
Global $label_en_server = GUICtrlCreateLabel("Адрес сервера:", 30, 232, 83, 20)
GUICtrlSetFont(-1, 10, 800, 0, "Arial Narrow")
Global $label_en_user = GUICtrlCreateLabel("Имя пользователя:", 30, 280, 109, 20)
GUICtrlSetFont(-1, 10, 800, 0, "Arial Narrow")
Global $label_en_password = GUICtrlCreateLabel("Пароль:", 30, 304, 50, 20)
GUICtrlSetFont(-1, 10, 800, 0, "Arial Narrow")
Global $input_en_server = GUICtrlCreateInput("", 144, 232, 313, 24)
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
Global $input_en_user = GUICtrlCreateInput("", 144, 280, 313, 24)
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
Global $input_en_password = GUICtrlCreateInput("", 144, 304, 313, 24)
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
Global $but_start_import = GUICtrlCreateButton("Восстановить", 268, 344, 91, 25)
Global $but_start_copy = GUICtrlCreateButton("Скопировать", 368, 344, 91, 25)
Global $label_mysql_cap1 = GUICtrlCreateLabel("Введите данные для подключения к Mysql:", 32, 192, 238, 20)
GUICtrlSetFont(-1, 10, 800, 0, "Arial Narrow")
Global $label_mysql_cap2 = GUICtrlCreateLabel("(если оставить поля пустыми, программа сама заполнит их)", 32, 208, 289, 20)
GUICtrlSetFont(-1, 9, 400, 2, "Arial Narrow")
Global $label_backup_path = GUICtrlCreateLabel("Укажите путь для резервной копии БД", 32, 136, 213, 20)
GUICtrlSetFont(-1, 10, 800, 0, "Arial Narrow")
Global $input_backup_path = GUICtrlCreateInput($backup_path, 32, 160, 425, 24)
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
Global $input_en_db = GUICtrlCreateInput("", 144, 256, 313, 24)
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
Global $label_en_bd = GUICtrlCreateLabel("База данных:", 30, 256, 109, 20)
GUICtrlSetFont(-1, 10, 800, 0, "Arial Narrow")
GUISetState(@SW_SHOW)
#EndRegion GUI ###

_ReadSettings()

While 1
	Local $nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
			; ------------------------------------------------------------------------------ ВОССТАНОВЛЕНИЕ MYSQL БД ---------------------------------------------------------------------------------------->
		Case $but_start_import
			$MySQL_credits[0] = GUICtrlRead($input_en_server)
			$MySQL_credits[1] = GUICtrlRead($input_en_user)
			$MySQL_credits[2] = GUICtrlRead($input_en_password)
			$MySQL_credits[3] = GUICtrlRead($input_en_db)

			$en_path = GUICtrlRead($input_en_path)
			$backup_path = GUICtrlRead($input_backup_path)

			If $MySQL_credits[0] == "" Or $MySQL_credits[1] == "" Or $MySQL_credits[2] == "" Or $MySQL_credits[3] == "" Then
				$en_status = _EnotStart($en_path) ; запускаем енот
				Sleep(1500) ; ждем 1.5 секунды после запуска
				_GetPass() ; получаем данные mysql
				ControlSetText($MysqlBackup_form, "", $input_en_server, $MySQL_credits[0])
				ControlSetText($MysqlBackup_form, "", $input_en_user, $MySQL_credits[1])
				ControlSetText($MysqlBackup_form, "", $input_en_password, $MySQL_credits[2])
				ControlSetText($MysqlBackup_form, "", $input_en_db, $MySQL_credits[3])
			EndIf

			_RunImport($MySQL_credits[0], $MySQL_credits[1], $MySQL_credits[2], $MySQL_credits[3]) ; Делаем импорт данных
			_SaveSettings($MySQL_credits[0], $MySQL_credits[1], $MySQL_credits[2], $MySQL_credits[3], $en_path, $backup_path) ; Записываем данные Mysql в Settings

			; ------------------------------------------------------------------------------ КОПИРОВАНИЕ MYSQL БД ------------------------------------------------------------------------------------------>
		Case $but_start_copy
			$MySQL_credits[0] = GUICtrlRead($input_en_server)
			$MySQL_credits[1] = GUICtrlRead($input_en_user)
			$MySQL_credits[2] = GUICtrlRead($input_en_password)
			$MySQL_credits[3] = GUICtrlRead($input_en_db)

			$en_path = GUICtrlRead($input_en_path)
			$backup_path = GUICtrlRead($input_backup_path)

			If $MySQL_credits[0] == "" Or $MySQL_credits[1] == "" Or $MySQL_credits[2] == "" Or $MySQL_credits[3] == "" Then
				$en_status = _EnotStart($en_path) ; запускаем енот
				Sleep(1500) ; ждем 1.5 секунды после запуска
				_GetPass() ; получаем данные mysql
				ControlSetText($MysqlBackup_form, "", $input_en_server, $MySQL_credits[0])
				ControlSetText($MysqlBackup_form, "", $input_en_user, $MySQL_credits[1])
				ControlSetText($MysqlBackup_form, "", $input_en_password, $MySQL_credits[2])
				ControlSetText($MysqlBackup_form, "", $input_en_db, $MySQL_credits[3])
			EndIf

			_RunBackup($MySQL_credits[0], $MySQL_credits[1], $MySQL_credits[2], $MySQL_credits[3]) ; Копируем данные
			_SaveSettings($MySQL_credits[0], $MySQL_credits[1], $MySQL_credits[2], $MySQL_credits[3], $en_path, $backup_path) ; Записываем данные Mysql в Settings
	EndSwitch
WEnd


Func _ReadSettings() ; Запуск программы
	If FileExists("Settings.ini") Then ; Чтение данных из Settings.ini (если есть)
		Global $settings_server = IniRead("Settings.ini", "Mysql", "Server", "") ; Адрес сервера
		Global $settings_login = IniRead("Settings.ini", "Mysql", "Login", "") ; Логин
		Global $settings_password = IniRead("Settings.ini", "Mysql", "Password", "") ; Пароль
		Global $settings_database = IniRead("Settings.ini", "Mysql", "Database", "") ; База данных

		$en_path = IniRead("Settings.ini", "Common", "Enot_Path", "C:\Triasoft\eNot")
		$backup_path = IniRead("Settings.ini", "Common", "Backup_Path", "C:\Distr\Mysql_backup")

		; --- Дешифруем логин и пароль
		$settings_server = _StringEncrypt(0, $settings_server, @ComputerName, 5)
		$settings_login = _StringEncrypt(0, $settings_login, @ComputerName, 5)
		$settings_password = _StringEncrypt(0, $settings_password, @ComputerName, 5)
		$settings_database = _StringEncrypt(0, $settings_database, @ComputerName, 5)
		; --- /

		; --- Записываем данные в форму
		ControlSetText($MysqlBackup_form, "", $input_en_path, $en_path)
		ControlSetText($MysqlBackup_form, "", $input_backup_path, $backup_path)

		ControlSetText($MysqlBackup_form, "", $input_en_server, $settings_server)
		ControlSetText($MysqlBackup_form, "", $input_en_user, $settings_login)
		ControlSetText($MysqlBackup_form, "", $input_en_password, $settings_password)
		ControlSetText($MysqlBackup_form, "", $input_en_db, $settings_database)
		; --- /
	EndIf
EndFunc   ;==>_ReadSettings

Func _SaveSettings($srv, $usr, $pas, $db, $enpath, $backpath) ; Шифруем и записываем данные в Settings.ini
	Local $strsrv = _StringEncrypt(1, $srv, @ComputerName, 5)
	Local $strusr = _StringEncrypt(1, $usr, @ComputerName, 5)
	Local $strpas = _StringEncrypt(1, $pas, @ComputerName, 5)
	Local $strdb = _StringEncrypt(1, $db, @ComputerName, 5)

	IniWrite("Settings.ini", "Common", "Enot_path", $enpath)
	IniWrite("Settings.ini", "Common", "Backup_path", $backpath)

	IniWrite("Settings.ini", "Mysql", "Server", $strsrv)
	IniWrite("Settings.ini", "Mysql", "Login", $strusr)
	IniWrite("Settings.ini", "Mysql", "Password", $strpas)
	IniWrite("Settings.ini", "Mysql", "Database", $strdb)
EndFunc   ;==>_SaveSettings


Func _EnotStart($path) ; Запуск енота
	If Not ProcessExists("eNot.exe") Then ; Проверяем, запущен ли Енот
		If FileExists($path) Then ; Ищем путь к программе
			Run($path & "\enot.exe") ; Запускаем енот
			WinWait("[CLASS:ThunderRT6MDIForm]", "", 450)
			Return ("NotLoaded")
		Else
			MsgBox("", "Программа не найдена", "Укажите верный путь к папке с енотом") ; Если путь к программе не найден
			Return ("WrongPath")
		EndIf
	Else
		Return ("Loaded")
	EndIf
EndFunc   ;==>_EnotStart

Func _GetPass() ; Получение данные об Mysql сервере
	If $en_status <> "WrongPath" Then ; если загрузили енот, то
		If WinExists("[CLASS:ThunderRT6MDIForm]", "") Then
			Local $en_handle = WinWait("[CLASS:ThunderRT6MDIForm]", "", 5)
			If Not WinExists("Настройки eNot", "") Then WinMenuSelectItem($en_handle, "", "&Программа", "Настройка")
			Local $en_set = WinWait("Настройки eNot")

			; --- Берём настройки Mysql из енота
			$MySQL_credits[0] = ControlGetText($en_set, '', '[CLASS:ThunderRT6TextBox; INSTANCE:16]') ; Сервер
			$MySQL_credits[1] = ControlGetText($en_set, '', '[CLASS:ThunderRT6TextBox; INSTANCE:14]') ; Пользователь
			$MySQL_credits[2] = ControlGetText($en_set, '', '[CLASS:ThunderRT6TextBox; INSTANCE:13]') ; Пароль
			$MySQL_credits[3] = ControlGetText($en_set, '', '[CLASS:ThunderRT6TextBox; INSTANCE:12]') ; База данных
			; --- /

			; Закрываем настройки и енот
			ControlClick($en_set, "", '[CLASS:ThunderRT6CommandButton; INSTANCE:1]')
			If $en_status == "NotLoaded" Then ; закроем енот, если ранее не был открыт
				WinClose($en_handle)
				If WinExists("eNot", "Run-time") Then WinClose("eNot", "Run-time")
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_GetPass

Func _RunBackup($srv, $usr, $pas, $db) ; Резервное копирование енота
	If $en_status <> "WrongPath" Then ; если загрузили енот, то
		TrayTip("", "Запускаем резервное копирование", 5)

		Local $date = @MDAY & '_' & @MON & '_' & @YEAR
		Local $time = @HOUR & '_' & @MIN
		Local $backup_directory = $backup_path & "\" & $date

		If DirGetSize($backup_directory) == -1 Then DirCreate($backup_directory)

		Local $mysqlCommand = @TempDir & "\mysqldump.exe --single-transaction --verbose " & "-h " & $srv & " -u " & $usr & " --password=" & $pas & " " & $db & " > """ & $backup_directory & "\" & $db & "_" & $time & ".sql"""
		RunWait(@ComSpec & " /c " & $mysqlCommand, "", @SW_SHOW)
		TrayTip("", "Резервное копирование завершено", 5)
	EndIf
EndFunc   ;==>_RunBackup

Func _RunImport($srv, $usr, $pas, $db) ; Резервное копирование енота
	Local $mysqlCommand
	If $en_status <> "WrongPath" Then ; если загрузили енот, то
		TrayTip("", "Запускаем резервное восстановление", 5)

		$import_directory = FileOpenDialog("Укажите путь к резервной копии БД", @WindowsDir & "\", "Резервная копия (*.sql)", 1)

		If FileExists($import_directory) == -1 Then
			MsgBox("", "Ошибка", "Не найдена резервная копия")
		Else
			$mysqlCommand = @TempDir & "\mysql.exe --verbose " & "-h " & $srv & " -u " & $usr & " --password=" & $pas & " " & $db & " < """ & $import_directory & ""
			RunWait(@ComSpec & " /c " & $mysqlCommand, "", @SW_SHOW)
			TrayTip("", "База данных восстановлена", 5)
		EndIf
	EndIf
EndFunc   ;==>_RunImport

Func _Password()
	$sPass = _StringEncrypt(0, $sPass, "Резервная копия", 5)
	Local $i = 0
	While 1
		$i += 1
		If $i == 4 Then Exit
		Local $sPass_tmp = InputBox("Mysql backup", "Введите пароль", "", "*", "", "140")

		If $sPass_tmp == $sPass Then
			ExitLoop
		Else
			MsgBox(0, "Неверный пароль", "Введите правильный пароль для того, чтобы запустить программу")
		EndIf
	WEnd
EndFunc   ;==>_Password
