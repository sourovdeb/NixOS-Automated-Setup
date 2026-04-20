# Copy AEON scripts into the running VM using a simple HTTP server.
# Run this from C:\Users\souro\Desktop\Arch_Linus

Write-Host "Starting local HTTP server on port 8000..." -ForegroundColor Yellow
Write-Host "Keep this window open while copying from the VM." -ForegroundColor Yellow
python -m http.server 8000