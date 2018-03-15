#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/SO
#AutoIt3Wrapper_Res_LegalCopyright=Ситников Виталий
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

$CertStore = ObjCreate("CAPICOM.Store")
$CertStore.Open (2, "REQUEST" , 0)
$Certificates = $CertStore.Certificates.Find(2, "Работник нотариальной конторы", 0) ; Только серты тех. работника
If $Certificates.count > 0  Then
	For $Cert In $Certificates
		$CertStore0 = ObjCreate("CAPICOM.Store") ; Личные серты
		$CertStore0.Open (2, "My" , 1)
		$CertStore0.Add($Cert)

		$CertStore1 = ObjCreate("CAPICOM.Store") ; Корневые серты
		$CertStore1.Open (2, "ROOT" , 1)
		$CertStore1.Add($Cert)

	Next
	$CertStore0.Close
	$CertStore1.Close
Else
	MsgBox("","Ошибка","Сертификат тех. работника не найден",3)
EndIf
$CertStore.Close

