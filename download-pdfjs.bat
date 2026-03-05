@echo off
echo ============================================
echo   PDF.js downloaden voor BriefAssistent
echo ============================================
echo.

if not exist "pdfjs" mkdir pdfjs

echo Downloaden van pdf.min.js...
powershell -Command "Invoke-WebRequest -Uri 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js' -OutFile 'pdfjs\pdf.min.js'"

echo Downloaden van pdf.worker.min.js...
powershell -Command "Invoke-WebRequest -Uri 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js' -OutFile 'pdfjs\pdf.worker.min.js'"

if exist "pdfjs\pdf.min.js" (
    echo.
    echo ============================================
    echo   OK! PDF.js succesvol gedownload.
    echo   U kunt de extensie nu laden in Edge.
    echo ============================================
) else (
    echo.
    echo FOUT: Download mislukt. Controleer uw internetverbinding.
)

echo.
pause
