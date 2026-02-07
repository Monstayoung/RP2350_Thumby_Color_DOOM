# Read from USB CDC Serial Port
param(
    [string]$PortName = "COM3",
    [int]$BaudRate = 115200
)

Write-Host "Opening $PortName at $BaudRate baud..."
Write-Host "Press Ctrl+C to exit"
Write-Host ""

try {
    $port = new-Object System.IO.Ports.SerialPort $PortName,$BaudRate,None,8,one
    $port.Open()
    
    Write-Host "Connected! Waiting for data..."
    Write-Host "============================================"
    
    while($true) {
        if ($port.BytesToRead -gt 0) {
            $line = $port.ReadLine()
            Write-Host $line
        }
        Start-Sleep -Milliseconds 10
    }
}
catch {
    Write-Host "ERROR: $_"
    Write-Host ""
    Write-Host "Available COM ports:"
    [System.IO.Ports.SerialPort]::getportnames()
}
finally {
    if ($port -ne $null) {
        $port.Close()
    }
}
