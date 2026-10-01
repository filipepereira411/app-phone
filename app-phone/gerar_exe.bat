@echo off
chcp 65001 > nul
title Servidor de Controlo Remoto (.BAT + HTML)

echo ===================================================
echo   A iniciar Servidor Nativo do Windows...
echo ===================================================

:: Deteta o IP local do seu PC automaticamente
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do set IP=%%a
set IP=%IP: =%

echo PC: Aceda a http://localhost:8080
echo Telemóvel: Aceda a http://%IP%:8080
echo ===================================================

:: Executa o PowerShell para criar o servidor e escutar os comandos vindos do HTML
powershell -NoProfile -ExecutionPolicy Bypass -Command " ^
    [void][Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); ^
    $listener = New-Object System.Net.HttpListener; ^
    $listener.Prefixes.Add('http://*:8080/'); ^
    $listener.Start(); ^
    while ($listener.IsListening) { ^
        $context = $listener.GetContext(); ^
        $req = $context.Request; ^
        $res = $context.Response; ^
        if ($req.Url.LocalPath -eq '/comando') { ^
            $acao = $req.QueryString['acao']; ^
            $x = [int]$req.QueryString['x']; ^
            $y = [int]$req.QueryString['y']; ^
            if ($acao -eq 'mover') { ^
                $pos = [System.Windows.Forms.Cursor]::Position; ^
                [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(($pos.X + $x), ($pos.Y + $y)); ^
            } ^
            if ($acao -eq 'clique') { ^
                $wsh = New-Object -ComObject WScript.Shell; ^
                $wsh.SendKeys(' '); ^
            } ^
            $buffer = [System.Text.Encoding]::UTF8.GetBytes('OK'); ^
            $res.ContentLength64 = $buffer.Length; ^
            $res.OutputStream.Write($buffer, 0, $buffer.Length); ^
            $res.Close(); ^
        } else { ^
            $html = Get-Content -Raw -Path 'index.html'; ^
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html); ^
            $res.ContentType = 'text/html; charset=utf-8'; ^
            $res.ContentLength64 = $buffer.Length; ^
            $res.OutputStream.Write($buffer, 0, $buffer.Length); ^
            $res.Close(); ^
        } ^
    }"
pause
