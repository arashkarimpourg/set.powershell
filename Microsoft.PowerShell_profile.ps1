oh-my-posh init pwsh --config C:\Users\arash\oh-my-posh\gruvbox.omp.json | Invoke-Expression

function cf {
    param (
        [string]$Alias
    )
    switch ($Alias) {
        "down" {
            Set-Location "C:\Users\arash\Downloads"
        }
        "desk" {
            Set-Location "C:\Users\arash\Desktop"
        }
        "pro" {
            Set-Location "C:\Users\arash\OneDrive\Projects"
        }
        "rust" {
            Set-Location "C:\Users\arash\OneDrive\Projects\RustPlayground"
        }
        "app" {
            Set-Location "C:\Users\arash\AppData"
        }
        "data" {
            Set-Location "C:\Users\arash\AppData"
        }
        "appdata" {
            Set-Location "C:\Users\arash\AppData"
        }
        "vim" {
            Set-Location "C:\Users\arash\AppData\Local\nvim"
        }
        default {
            Set-Location $Alias
        }
    }
}

function icon {
    param(
        [string]$File1,
        [string]$File2,
        [switch]$Small,
        [switch]$S,
        [switch]$Big,
        [switch]$B
    )

    if ($File1 -ne "" -and $File2 -eq "") {

        $bigIconSizes = "256,128,96,72,64,48"
        $smallIconSizes = "32,24,16"
        $outputFile = [System.IO.Path]::GetFileNameWithoutExtension($File1)
        $ext = [System.IO.Path]::GetExtension($File1)

        if ($ext -eq ".png" -or $ext -eq ".webp") {
            if ($Small -or $S) {
                $outputFile += "-s.ico"
                $iconSizes = $smallIconSizes
            }
            elseif ($Big -or $B) {
                $outputFile += "-b.ico"
                $iconSizes = $bigIconSizes
            }
            else {
                $outputFile += ".ico"
                $iconSizes = "$bigIconSizes,$smallIconSizes"
            }
            
            $command = "convert '$File1' -define icon:auto-resize=$iconSizes '$outputFile'"
            Invoke-Expression $command
            Write-Host "$outputFile"
        }
    }
    elseif ($File1 -ne "" -and $File2 -ne "") {
        $ext1 = [System.IO.Path]::GetExtension($File1)
        $ext2 = [System.IO.Path]::GetExtension($File2)
        if ($ext1 -eq ".ico" -and $ext2 -eq ".ico") {
            $File1WithoutSuffix = $File1 -replace '(-[sb])\.ico$', '.ico'
            Write-Host $File1WithoutSuffix
            $File2WithoutSuffix = $File2 -replace '(-[sb])\.ico$', '.ico'
            Write-Host $File2WithoutSuffix
            if ($File1WithoutSuffix -eq $File2WithoutSuffix) {
                $outputFile = $File1 -replace '(-[sb])\.ico$', '.ico'
            }
            else {
                $outputFile = "icon.ico"
            }
            $command = "convert '$File1' '$File2' '$outputFile'"
            Invoke-Expression $command
            Write-Host "$outputFile"
        }
    }
}

Remove-Item Alias:\ls -ErrorAction SilentlyContinue
function ls {
    param (
        [string]$Path = (Get-Location),
        [switch]$Recursive
    )

    $items = Get-ChildItem $Path
    if ($Recursive) {
        $items = Get-ChildItem $Path -Recurse
    }

    $folderPath = $Path
    $dateTimeFormat = "yyyy-MM-dd hh:mm tt"

    $table = @()

    foreach ($item in $items) {
        if ($item -is [System.IO.FileInfo]) {
            $lastModified = $item.LastWriteTime.ToString($dateTimeFormat)
            $fileName = $item.Name

            # Convert the file size to KB, MB, or GB
            $fileSize = $item.Length
            if ($fileSize -ge 1GB) {
                $fileSizeFormatted = "{0:N2} GB" -f ($fileSize / 1GB)
            } elseif ($fileSize -ge 1MB) {
                $fileSizeFormatted = "{0:N2} MB" -f ($fileSize / 1MB)
            } else {
                $fileSizeFormatted = "{0:N2} KB" -f ($fileSize / 1KB)
            }

            $table += New-Object PSObject -property @{
                "Last Modified" = "`e[90m$lastModified`e[0m "
                "Size" = "`e[90m$fileSizeFormatted`e[0m "
                "Name" = "$fileName"
            }
        } elseif ($item -is [System.IO.DirectoryInfo]) {
            $lastModified = $item.LastWriteTime.ToString($dateTimeFormat)
            $folderName = $item.Name

            $table += New-Object PSObject -property @{
                "Last Modified" = "`e[90m$lastModified`e[0m "
                "Size" = ""
                "Name" = "`e[44;97m$folderName`e[0m"  # Blue background for folder names
            }
        }
    }

    #Write-Host $folderPath
    Write-Host "$folderPath"  # Blue background for folder names

    $table | Format-Table -Property "Last Modified", "Size", "Name" -AutoSize
}