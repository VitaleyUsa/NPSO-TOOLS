#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\..\Games\Fallout Nevada\FoN2.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Res_Comment=Нотариальная палата Свердловской области
#AutoIt3Wrapper_Res_Description=Восстановление базы данных Mysql
#AutoIt3Wrapper_Res_Fileversion=1.0.0.14
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Ситников Виталий
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=highestAvailable
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/SO
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#pragma compile(UPX, False)

#include <File.au3>
#include <Misc.au3>
#include <GUIConstantsEx.au3>

Global $sql_path
Global $sql_temp
Global $aRecords

Global $date = @MON & "/" & @MDAY & "/" & @YEAR
Global $line_pos

$sql_path = RegRead("HKLM\System\CurrentControlSet\Services\MySql", "ImagePath") ; Находим путь к
$sql_path = _StringBetween2($sql_path, 'defaults-file="', '"') ; my.ini
$sql_temp = $sql_path
$sql_path = FileOpen($sql_path, 1) ; Открываем его

If $sql_path Then
	SplashTextOn("Статус", "Останавливаем MySql и исправляем БД", 550, 30, 0, 150, 33, "", 10)
	RunWait(@ComSpec & ' /c net stop MySql', '', @SW_HIDE) ; Останавливаем mysql

	FileWrite($sql_path, '#БД было восстановлено = ' & $date & @CRLF) ;
	FileWrite($sql_path, "innodb_force_recovery=2") ; Дописываем в my.ini параметр для восстановления
	FileClose($sql_path) ;

	RunWait(@ComSpec & ' /c net start MySql', '', @SW_HIDE) ; Запускаем mysql

	ControlSetText("Статус", '', 'Static1', "Запускаем MySql в штатном режиме")
	RunWait(@ComSpec & ' /c net stop MySql', '', @SW_HIDE) ; Снова выключаем mysql, чтобы убрать параметр для восстановления

	_FileReadToArray($sql_temp, $aRecords) ;

	For $line_pos = 1 To $aRecords[0] ; Находим в my.ini параметр восстановления
		If StringInStr($aRecords[$line_pos], "innodb_force_recovery=2") Then _FileWriteToLine($sql_temp, $line_pos, "", 1) ; и удаляем его
	Next ;


	RunWait(@ComSpec & ' /c net start MySql', '', @SW_HIDE)

	ControlSetText("Статус", '', 'Static1', "Восстановление завершено")
	Sleep(3000)
Else
	SplashTextOn("Статус", "Не найден путь к MySql", 550, 30, 0, 150, 33, "", 10)
	Sleep(3000)
EndIf


Func _StringBetween2($s, $from, $to) ;	Функция для поиска строк
	Local $x = StringInStr($s, $from) + StringLen($from)
	Local $y = StringInStr(StringTrimLeft($s, $x), $to)
	Return StringMid($s, $x, $y)
EndFunc   ;==>_StringBetween2
