$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Runtime.WindowsRuntime
Add-Type -AssemblyName System.Drawing
[Windows.Storage.StorageFile,Windows.Storage,ContentType=WindowsRuntime] | Out-Null
[Windows.Data.Pdf.PdfDocument,Windows.Data.Pdf,ContentType=WindowsRuntime] | Out-Null
[Windows.Data.Pdf.PdfPageRenderOptions,Windows.Data.Pdf,ContentType=WindowsRuntime] | Out-Null
[Windows.Storage.Streams.IRandomAccessStream,Windows.Storage.Streams,ContentType=WindowsRuntime] | Out-Null
$asTaskGeneric=([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {$_.Name -eq 'AsTask' -and $_.IsGenericMethod -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'})[0]
$asTaskAction=([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {$_.Name -eq 'AsTask' -and !$_.IsGenericMethod -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncAction'})[0]
function Await-Result($operation,[Type]$type){
 $task=$asTaskGeneric.MakeGenericMethod($type).Invoke($null,@($operation))
 $task.GetAwaiter().GetResult()
}
function Await-Action($operation){
 $task=$asTaskAction.Invoke($null,@($operation))
 $task.GetAwaiter().GetResult()
}
$taskDir='E:\MealsGo\PTTKHT\PTTK_Cine\.report-edit-20261112'
$renderDir=Join-Path $taskDir 'pages'
New-Item -ItemType Directory -Force -Path $renderDir | Out-Null
$file=Await-Result ([Windows.Storage.StorageFile]::GetFileFromPathAsync((Join-Path $taskDir 'updated-report.pdf'))) ([Windows.Storage.StorageFile])
$pdf=Await-Result ([Windows.Data.Pdf.PdfDocument]::LoadFromFileAsync($file)) ([Windows.Data.Pdf.PdfDocument])
for($i=0;$i -lt $pdf.PageCount;$i++){
 $page=$pdf.GetPage($i)
 $options=[Windows.Data.Pdf.PdfPageRenderOptions]::new();$options.DestinationWidth=1400
 $stream=[IO.File]::Open((Join-Path $renderDir ('page-{0:D2}.png' -f ($i+1))),[IO.FileMode]::Create,[IO.FileAccess]::ReadWrite)
 $random=[System.IO.WindowsRuntimeStreamExtensions]::AsRandomAccessStream($stream)
 try{Await-Action ($page.RenderToStreamAsync($random,$options))}finally{$random.Dispose();$stream.Dispose();$page.Dispose()}
}
'Rendered pages: '+$pdf.PageCount
# Contact sheets are QA only; source media is never altered.
$files=@(Get-ChildItem $renderDir -Filter 'page-*.png' | Sort-Object Name)
$thumbW=350;$thumbH=520;$cols=4;$rows=3;$perSheet=$cols*$rows
for($offset=0;$offset -lt $files.Count;$offset+=$perSheet){
 $canvas=[Drawing.Bitmap]::new($thumbW*$cols,$thumbH*$rows)
 $g=[Drawing.Graphics]::FromImage($canvas);$g.Clear([Drawing.Color]::LightGray)
 $font=[Drawing.Font]::new('Arial',12)
 try{
  for($j=0;$j -lt $perSheet -and ($offset+$j) -lt $files.Count;$j++){
   $img=[Drawing.Image]::FromFile($files[$offset+$j].FullName)
   try{
    $x=($j%$cols)*$thumbW;$y=[Math]::Floor($j/$cols)*$thumbH
    $scale=[Math]::Min(($thumbW-10)/$img.Width,($thumbH-28)/$img.Height)
    $w=[int]($img.Width*$scale);$h=[int]($img.Height*$scale)
    $g.DrawImage($img,[int]$x,[int]$y,$w,$h)
    $g.DrawString(('Page '+($offset+$j+1)),$font,[Drawing.Brushes]::Black,[single]$x,[single]($y+$thumbH-23))
   }finally{$img.Dispose()}
  }
  $canvas.Save((Join-Path $taskDir ('contact-{0:D2}.png' -f ([int]($offset/$perSheet)+1))),[Drawing.Imaging.ImageFormat]::Png)
 }finally{$font.Dispose();$g.Dispose();$canvas.Dispose()}
}
