Write-Host "what would u like to do?"
Write-Host " A. collect the baseline?"
Write-Host " B. Begin monitoring files with saved basline?"

$response = Read-Host -Prompt " Plz enter 'A' or 'B' "

Write-Host""

Function Calculate-File-Hash($filepath){
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash

    }
    
Function Erase-Baseline-If-Already-Exist() {
   $baselineExists = Test-Path -Path .\baseline.txt

   if ($baselineExists) {
        #Delete it
        Remove-Item -Path .\baseline.txt
        }
    }



if ($response -eq "A".ToUpper()){
    #Delete baseline.txt if already exists
      Erase-Baseline-If-Already-Exist

    #calculate hash frm the target  files and store in baseline.txt
    Write-Host "calculate hashes , make new baseline.txt" -ForegroundColor Cyan

    #collect all files in the target folder
    $files = Get-ChildItem -Path .\Files
    
    #for each file calculate the hash and write to baseline.txt
    foreach ($f in $files){
      $hash = Calculate-File-Hash $f.FullName
      "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
    }

}

elseif ($response -eq "B".ToUpper()) {

    $fileHashDictonary = @{}

    #load file|hash from baseline.txt and store them in dictonary
     $filePathAndHashes = Get-Content -Path .\baseline.txt
     
     foreach ($f in $filePathAndHashes) {
         $fileHashDictonary.Add($f.Split("|")[0], $f.Split("|")[1])
     }

    #begin monitoring files with saved baseline
    while($true){
    Start-Sleep -Seconds 1

     $files = Get-ChildItem -Path .\Files

    #for each file calculate the hash and write to baseline.txt
    foreach ($f in $files){
      $hash = Calculate-File-Hash $f.FullName
      #"$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append

      if ($fileHashDictonary[$hash.Path] -eq $null){

      # a new file has been created!
      Write-Host "$($hash.Path) has been created!" -ForegroundColor DarkRed

      
            }
        #notify if a file has been changed
        if ($fileHashDictonary[$hash.Path] -eq $hash.Hash){
        #the file has not changed
        }
        else {
            # file has been changed, Attention
            Write-Host "$($hash.Path) has changed" -ForegroundColor Red
        }
        }

        foreach ($key in $fileHashDictonary.Keys){
        $baselineFileStillExists = Test-Path -Path $key
        if (-Not $baselineFileStillExists) {
        # fill dlt
        Write-Host "$($key) has been deleted" -ForegroundColor DarkMagenta
        }
        }
    }
     
      
}