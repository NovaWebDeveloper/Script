
# Set-Wallpaper.ps1
# Downloads an image and sets it as the current user's wallpaper.

$ImageUrl = "https://picsum.photos/1920/1080"
$WallpaperFolder = Join-Path $env:LOCALAPPDATA "WallpaperProject"
$WallpaperPath = Join-Path $WallpaperFolder "wallpaper.jpg"

New-Item -Path $WallpaperFolder -ItemType Directory -Force | Out-Null

try {
    Invoke-WebRequest -Uri $ImageUrl -OutFile $WallpaperPath -UseBasicParsing -ErrorAction Stop

    if (-not (Test-Path $WallpaperPath)) {
        throw "Image download failed."
    }

    Add-Type @"
using System.Runtime.InteropServices;
public class WallpaperSetter {
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int action, int param, string path, int flags);
}
"@

    $result = [WallpaperSetter]::SystemParametersInfo(20, 0, $WallpaperPath, 3)

    if ($result -ne 0) {
        Write-Host "Wallpaper updated successfully." -ForegroundColor Green
    } else {
        throw "Windows could not apply the wallpaper."
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
