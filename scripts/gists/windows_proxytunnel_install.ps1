# Define the directory where the file will be downloaded
$downloadDir = "$home\proxytunnel"

# Create the directory if it doesn't exist
if (-not (Test-Path -Path $downloadDir)) {
    New-Item -ItemType Directory -Path $downloadDir | Out-Null
    Write-Host "Created directory: $downloadDir"
}

# URL of the file to download (replace with your actual file URL)
$fileUrl = "https://github.com/proxytunnel/proxytunnel/releases/download/v1.10.20210604/proxytunnel.zip"

# Extract the filename from the URL
$fileName = [System.IO.Path]::GetFileName($fileUrl)

# Full path where the file will be saved
$filePath = Join-Path -Path $downloadDir -ChildPath $fileName

# Download the file
try {
    Invoke-WebRequest -Uri $fileUrl -OutFile $filePath
    Write-Host "File downloaded successfully to: $filePath"
} catch {
    Write-Host "Failed to download file. Error: $_"
    exit
}

# Unzip the downloaded file
try {
    Expand-Archive -Path $filePath -DestinationPath $downloadDir -Force
    Write-Host "File unzipped successfully to: $downloadDir"
    
    # Remove the zip file after extraction
    Remove-Item -Path $filePath
    Write-Host "Removed zip file: $filePath"
} catch {
    Write-Host "Failed to unzip file. Error: $_"
    exit
}

# Add the directory to the system PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath -notlike "*$downloadDir*") {
    $newPath = "$currentPath;$downloadDir"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "Added $downloadDir to the system PATH"
} else {
    Write-Host "$downloadDir is already in the system PATH"
}

# Refresh the current session's PATH
$env:Path = [Environment]::GetEnvironmentVariable("Path", "User")

Write-Host "Script completed. You may need to restart your terminal for PATH changes to take effect."

Write-Host "Installation completed. Press Enter to exit"
pause