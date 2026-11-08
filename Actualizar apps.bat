@echo off
rem Doble clic aqui para actualizar las apps desde los archivos de Descargas
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Actualizar apps.ps1"
if errorlevel 1 pause
