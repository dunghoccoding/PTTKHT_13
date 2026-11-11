$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$sourcePath='E:\MealsGo\PTTKHT\13_B23DCCN211.docx'
$taskDir='E:\MealsGo\PTTKHT\PTTK_Cine\.report-edit-20261112'
$outputPath='E:\MealsGo\PTTKHT\PTTK_Cine\13_B23DCCN211_cap_nhat_phan_viet.docx'
$plan=Get-Content -Raw -Encoding UTF8 (Join-Path $taskDir 'plan.json') | ConvertFrom-Json
$sourceHash=(Get-FileHash -LiteralPath $sourcePath).Hash
$srcStream=[IO.File]::Open($sourcePath,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::ReadWrite)
$src=[IO.Compression.ZipArchive]::new($srcStream,[IO.Compression.ZipArchiveMode]::Read)
try {
 $reader=[IO.StreamReader]::new($src.GetEntry('word/document.xml').Open())
 $xml=[Xml.XmlDocument]::new(); $xml.PreserveWhitespace=$true
 $xml.LoadXml($reader.ReadToEnd()); $reader.Dispose()
 $w='http://schemas.openxmlformats.org/wordprocessingml/2006/main'
 $ns=[Xml.XmlNamespaceManager]::new($xml.NameTable); $ns.AddNamespace('w',$w)
 $paras=@($xml.SelectNodes('//w:body//w:p',$ns))
 if($paras.Count -ne 692){throw "Source changed: $($paras.Count) paragraphs"}
 if((($paras[644].SelectNodes('.//w:t',$ns)|ForEach-Object InnerText)-join '') -notlike '*gdHome1.jsp*'){throw 'Source scenario moved'}
 $drawings=@($xml.SelectNodes('//w:drawing|//w:pict',$ns)|ForEach-Object OuterXml)
 $changes=[Collections.Generic.List[object]]::new()
 foreach($change in $plan.replace.PSObject.Properties){
  $idx=[int]$change.Name; $p=$paras[$idx-1]
  if($p.SelectSingleNode('.//w:drawing|.//w:pict',$ns)){throw "Drawing paragraph $idx"}
  $ts=@($p.SelectNodes('.//w:t',$ns)); if(!$ts.Count){throw "Missing text $idx"}
  $before=($ts|ForEach-Object InnerText)-join ''
  $ts[0].InnerText=[string]$change.Value
  [void]$ts[0].SetAttribute('space','http://www.w3.org/XML/1998/namespace','preserve')
  for($j=1;$j -lt $ts.Count;$j++){$ts[$j].InnerText=''}
  foreach($b in @($p.SelectNodes('.//w:tab|.//w:br[not(@w:type="page")]',$ns))){[void]$b.ParentNode.RemoveChild($b)}
  $changes.Add([pscustomobject]@{paragraph=$idx;before=$before;after=[string]$change.Value})
 }
 $sample=$paras[78]; $inserted=0
 foreach($block in $plan.insert){
  $anchor=$paras[[int]$block.after-1]
  $blockOffset=0
  foreach($text in $block.texts){
   $p=$xml.CreateElement('w','p',$w)
   $pr=$sample.SelectSingleNode('./w:pPr',$ns)
   if($pr){[void]$p.AppendChild($pr.CloneNode($true))}
   foreach($n in @($p.SelectNodes('./w:pPr/w:numPr|./w:pPr/w:sectPr|./w:pPr/w:pageBreakBefore',$ns))){[void]$n.ParentNode.RemoveChild($n)}
   $r=$xml.CreateElement('w','r',$w);$rp=$sample.SelectSingleNode('./w:r/w:rPr',$ns)
   if($rp){[void]$r.AppendChild($rp.CloneNode($true))}
   if($block.after -eq 16 -and $blockOffset -eq 0){
    $runPr=$r.SelectSingleNode('./w:rPr',$ns)
    if(!$runPr){$runPr=$xml.CreateElement('w','rPr',$w);[void]$r.AppendChild($runPr)}
    [void]$runPr.AppendChild($xml.CreateElement('w','b',$w))
   }
   $t=$xml.CreateElement('w','t',$w);$t.InnerText=[string]$text
   [void]$r.AppendChild($t);[void]$p.AppendChild($r)
   [void]$anchor.ParentNode.InsertAfter($p,$anchor);$anchor=$p
   $inserted++;$blockOffset++
  }
 }
 $newDrawings=@($xml.SelectNodes('//w:drawing|//w:pict',$ns)|ForEach-Object OuterXml)
 if(($drawings -join "`n") -cne ($newDrawings -join "`n")){throw 'Drawing changed'}
 $destStream=[IO.File]::Open($outputPath,[IO.FileMode]::Create,[IO.FileAccess]::ReadWrite)
 $dest=[IO.Compression.ZipArchive]::new($destStream,[IO.Compression.ZipArchiveMode]::Create)
 try{
  foreach($entry in $src.Entries){
   $out=$dest.CreateEntry($entry.FullName,[IO.Compression.CompressionLevel]::Optimal);$out.LastWriteTime=$entry.LastWriteTime
   $os=$out.Open()
   try{
    if($entry.FullName -eq 'word/document.xml'){
     $settings=[Xml.XmlWriterSettings]::new();$settings.Encoding=[Text.UTF8Encoding]::new($false);$settings.CloseOutput=$false
     $writer=[Xml.XmlWriter]::Create($os,$settings);$xml.Save($writer);$writer.Dispose()
    }else{$ins=$entry.Open();try{$ins.CopyTo($os)}finally{$ins.Dispose()}}
   }finally{$os.Dispose()}
  }
 }finally{$dest.Dispose();$destStream.Dispose()}
 $changes|ConvertTo-Json -Depth 4|Set-Content -Encoding UTF8 (Join-Path $taskDir 'changes.json')
 $hash=[Security.Cryptography.SHA256]::Create();$check=[IO.Compression.ZipFile]::OpenRead($outputPath);$preserved=0;$media=0
 try{
  foreach($entry in $src.Entries){
   if($entry.FullName -eq 'word/document.xml'){continue}
   $other=$check.GetEntry($entry.FullName);if(!$other){throw "Missing $($entry.FullName)"}
   $a=$entry.Open();$b=$other.Open()
   try{if([Convert]::ToBase64String($hash.ComputeHash($a)) -cne [Convert]::ToBase64String($hash.ComputeHash($b))){throw "Changed $($entry.FullName)"}}finally{$a.Dispose();$b.Dispose()}
   $preserved++;if($entry.FullName.StartsWith('word/media/')){$media++}
  }
 }finally{$check.Dispose();$hash.Dispose()}
 if((Get-FileHash -LiteralPath $sourcePath).Hash -cne $sourceHash){throw 'Source modified'}
 [pscustomobject]@{output=$outputPath;replaced=$changes.Count;inserted=$inserted;preservedParts=$preserved;preservedMedia=$media;preservedDrawings=$drawings.Count;sourceUnchanged=$true}|ConvertTo-Json
}finally{$src.Dispose();$srcStream.Dispose()}
