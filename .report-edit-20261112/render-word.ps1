$ErrorActionPreference='Stop'
$taskDir='E:\MealsGo\PTTKHT\PTTK_Cine\.report-edit-20261112'
$docPath='E:\MealsGo\PTTKHT\PTTK_Cine\13_B23DCCN211_cap_nhat_phan_viet.docx'
$pdfPath=Join-Path $taskDir 'updated-report.pdf'
$word=New-Object -ComObject Word.Application
$progressPath=Join-Path $taskDir 'render-progress.txt'
'Word started' | Set-Content $progressPath
$document=$null
try{
 $word.Visible=$false
 $word.DisplayAlerts=0
 $word.AutomationSecurity=3
 $word.Options.UpdateLinksAtOpen=$false
 'Opening document' | Add-Content $progressPath
 $document=$word.Documents.OpenNoRepairDialog($docPath,$false,$true,$false)
 'Document opened' | Add-Content $progressPath
 'Exporting PDF directly' | Add-Content $progressPath
 $document.SaveAs2($pdfPath,17)
 'PDF exported' | Add-Content $progressPath
 $document.Content.Text | Set-Content -Encoding UTF8 (Join-Path $taskDir 'word-render-text.txt')
 [pscustomobject]@{pdf=$pdfPath}|ConvertTo-Json
}finally{
 if($document){$document.Close(0);[void][Runtime.InteropServices.Marshal]::ReleaseComObject($document)}
 $word.Quit(0)
 [void][Runtime.InteropServices.Marshal]::ReleaseComObject($word)
}
