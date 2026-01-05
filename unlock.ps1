try {
    # Load WPF assembly
    Add-Type -AssemblyName PresentationFramework

    # Create and configure file dialog
    $fileDialog = New-Object Microsoft.Win32.OpenFileDialog
    $fileDialog.Filter = "Secret files (*.secret)|*.secret|All files (*.*)|*.*"
    $fileDialog.Title = "Select an encrypted file to unlock"

    # Show dialog and get selected file
    $result = $fileDialog.ShowDialog()

    if ($result -eq $true) {
        $inputFile = $fileDialog.FileName
    } else {
    Write-Host "No file selected. Exiting..." -ForegroundColor Yellow
    exit
    }

    # Check if file exists
    if (-not (Test-Path $inputFile)) {
        Write-Host "File not found: $inputFile" -ForegroundColor Red
        exit
    }

    # Check if file has .secret extension
    if ([System.IO.Path]::GetExtension($inputFile) -ne ".secret") {
        Write-Host "Error: File must have .secret extension" -ForegroundColor Red
        exit
    }
    $pass = Read-Host "Enter password to unlock the file" -AsSecureString
    $passPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))

    $sha256 = New-Object System.Security.Cryptography.SHA256Managed
    $key = $sha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($passPlain))
    $encryptedContent = Get-Content $inputFile

    $secureString = ConvertTo-SecureString -String $encryptedContent -Key $key -ErrorAction Stop

    $decrypted = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString))

    Write-Host "--------------------------------"
    Write-Host "Your data is:" -ForegroundColor Cyan
    Write-Host $decrypted -ForegroundColor Yellow
    Write-Host "--------------------------------"
} catch {
    Write-Host "`n" -NoNewline
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                                                        ║" -ForegroundColor Red
    Write-Host "║             ❌ DECRYPTION FAILED ❌                    ║" -ForegroundColor Red
    Write-Host "║                                                        ║" -ForegroundColor Red
    Write-Host "║  Incorrect password or the file may be corrupted.      ║" -ForegroundColor Red
    Write-Host "║  Please verify your password and try again.            ║" -ForegroundColor Red
    Write-Host "║                                                        ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
}
