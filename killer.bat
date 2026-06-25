@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion
title Gerenciador de Processos - TI

:: ============================================================
:: CORES VIA ANSI (funciona no Windows 10 build 1511+ e Windows 11)
:: ============================================================
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

set "RESET=%ESC%[0m"
set "BOLD=%ESC%[1m"
set "CYAN=%ESC%[96m"
set "CYAN_D=%ESC%[36m"
set "GREEN=%ESC%[92m"
set "RED=%ESC%[91m"
set "YELLOW=%ESC%[93m"
set "BLUE=%ESC%[94m"
set "MAGENTA=%ESC%[95m"
set "WHITE=%ESC%[97m"
set "GRAY=%ESC%[90m"

:: ============================================================
::  CONFIGURACOES
:: ============================================================
set LOG_DIR=C:\Logs\GerenciadorProcessos
set LOG_FILE=%LOG_DIR%\processos_%COMPUTERNAME%.log
set SESSAO_TEMP=%TEMP%\gp_sessao_%RANDOM%.tmp
set SESSAO_COUNT=0

if not exist "%LOG_DIR%" (
    mkdir "%LOG_DIR%" 2>nul
    if !ERRORLEVEL! neq 0 (
        set LOG_FILE=%TEMP%\processos_%COMPUTERNAME%.log
    )
)

echo. > "%SESSAO_TEMP%"

:: ============================================================
:MENU
cls
echo %CYAN%  ╔══════════════════════════════════════════════════════╗%RESET%
echo %CYAN%  ║%BOLD%%WHITE%          GERENCIADOR DE PROCESSOS - TI              %RESET%%CYAN%║%RESET%
echo %CYAN%  ╠══════════════════════════════════════════════════════╣%RESET%
echo %CYAN%  ║%RESET%  %YELLOW%Usuario%RESET% : %WHITE%%USERNAME%%RESET%
echo %CYAN%  ║%RESET%  %YELLOW%Maquina%RESET% : %WHITE%%COMPUTERNAME%%RESET%
echo %CYAN%  ║%RESET%  %YELLOW%Data/Hr%RESET% : %WHITE%%DATE% - %TIME:~0,8%%RESET%
echo %CYAN%  ╠══════════════════════════════════════════════════════╣%RESET%
echo %CYAN%  ║%RESET%                                                      %CYAN%║%RESET%
echo %CYAN%  ║%RESET%    %GREEN%[1]%RESET%  Listar %WHITE%TODOS%RESET% os processos                    %CYAN%║%RESET%
echo %CYAN%  ║%RESET%    %GREEN%[2]%RESET%  %WHITE%Filtrar%RESET% processos por nome                   %CYAN%║%RESET%
echo %CYAN%  ║%RESET%    %BLUE%[3]%RESET%  Ver %WHITE%historico%RESET% da sessao                       %CYAN%║%RESET%
echo %CYAN%  ║%RESET%    %RED%[0]%RESET%  Sair                                          %CYAN%║%RESET%
echo %CYAN%  ║%RESET%                                                      %CYAN%║%RESET%
echo %CYAN%  ╚══════════════════════════════════════════════════════╝%RESET%
echo.
set "OPCAO="
echo  %YELLOW%Escolha uma opcao:%RESET%
set /p OPCAO="  > "

if "%OPCAO%"=="1" goto LISTAR_TUDO
if "%OPCAO%"=="2" goto FILTRAR
if "%OPCAO%"=="3" goto HISTORICO
if "%OPCAO%"=="0" goto SAIR
goto MENU

:: ============================================================
:LISTAR_TUDO
cls
echo %CYAN%  ╔══════════════════════════════════════════════════════╗%RESET%
echo %CYAN%  ║%BOLD%%WHITE%           TODOS OS PROCESSOS EM EXECUCAO             %RESET%%CYAN%║%RESET%
echo %CYAN%  ╚══════════════════════════════════════════════════════╝%RESET%
echo.
tasklist /FO TABLE /NH
echo.
echo %CYAN%  ══════════════════════════════════════════════════════%RESET%
goto ENCERRAR_PROCESSO

:: ============================================================
:FILTRAR
cls
echo %CYAN%  ╔══════════════════════════════════════════════════════╗%RESET%
echo %CYAN%  ║%BOLD%%WHITE%              FILTRAR PROCESSOS POR NOME              %RESET%%CYAN%║%RESET%
echo %CYAN%  ╚══════════════════════════════════════════════════════╝%RESET%
echo.
set "FILTRO="
echo  %YELLOW%Digite parte do nome %GRAY%(ex: chrome, outlook, java)%YELLOW%:%RESET%
set /p FILTRO="  > "
if "!FILTRO!"=="" goto MENU

echo.
echo  %CYAN_D%Exibindo processos contendo:%RESET% %WHITE%"!FILTRO!"%RESET%
echo  %GRAY%──────────────────────────────────────────────────────%RESET%
echo.
echo  %YELLOW%Nome do Processo               PID        Sessao     Mem%RESET%
echo  %GRAY%------------------------------ ---------- ---------- --------%RESET%
tasklist /FO TABLE /NH | findstr /I "!FILTRO!"
echo.
echo %CYAN%  ══════════════════════════════════════════════════════%RESET%
goto ENCERRAR_PROCESSO

:: ============================================================
:ENCERRAR_PROCESSO
echo.
set "PID="
echo  %YELLOW%Digite o PID para encerrar %GRAY%(ou ENTER para voltar ao menu)%YELLOW%:%RESET%
set /p PID="  > "
if "!PID!"=="" goto MENU

echo !PID!| findstr /R "^[0-9][0-9]*$" > nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo.
    echo  %RED%[AVISO]%RESET% PID invalido. Digite apenas numeros.
    echo.
    pause
    goto MENU
)

set "PROC_NOME="
for /f "tokens=1" %%A in ('tasklist /FI "PID eq !PID!" /FO CSV /NH 2^>nul') do (
    if not defined PROC_NOME set "PROC_NOME=%%~A"
)

if "!PROC_NOME!"=="" (
    echo.
    echo  %RED%[AVISO]%RESET% Nenhum processo encontrado com PID %CYAN%!PID!%RESET%.
    echo          Verifique se o PID ainda esta ativo na lista.
    echo.
    pause
    goto MENU
)

echo.
echo  %MAGENTA%╔──────────────────────────────────────────────────╗%RESET%
echo  %MAGENTA%║%RESET%  %YELLOW%Processo%RESET% : %WHITE%!PROC_NOME!%RESET%
echo  %MAGENTA%║%RESET%  %YELLOW%PID     %RESET% : %CYAN%!PID!%RESET%
echo  %MAGENTA%║%RESET%  %YELLOW%Acao    %RESET% : %RED%Encerramento forcado ^(taskkill /F^)%RESET%
echo  %MAGENTA%╚──────────────────────────────────────────────────╝%RESET%
echo.
set "CONFIRM="
echo  %YELLOW%Confirma o encerramento? %GREEN%[S]%RESET% Sim  /  %RED%[N]%RESET% Cancelar%YELLOW%:%RESET%
set /p CONFIRM="  > "

:: Remove espacos extras da entrada (evita erros de digitacao)
set "CONFIRM=!CONFIRM: =!"

if /I "!CONFIRM!" neq "S" (
    echo.
    echo  %YELLOW%Operacao cancelada pelo usuario.%RESET%
    echo.
    pause
    goto MENU
)

echo.
taskkill /PID !PID! /F > nul 2>&1

:: ============================================================
:: CORRECAO: Captura o ERRORLEVEL imediatamente apos o taskkill
:: e usa gotos separados em vez de if/else com call aninhado.
:: O uso de call dentro de if/else pode corromper o fluxo do CMD
:: causando o fechamento indevido do terminal.
:: ============================================================
set "KILL_ERR=!ERRORLEVEL!"

if "!KILL_ERR!"=="0" goto KILL_SUCESSO
goto KILL_FALHA

:KILL_SUCESSO
echo  %GREEN%[OK]%RESET% %WHITE%"!PROC_NOME!"%RESET% %GRAY%(PID:%RESET% %CYAN%!PID!%RESET%%GRAY%)%RESET% encerrado com sucesso!
call :REGISTRAR_LOG "SUCESSO" "!PID!" "!PROC_NOME!"
call :REGISTRAR_SESSAO "OK  " "!PID!" "!PROC_NOME!"
set /a SESSAO_COUNT+=1
goto KILL_FIM

:KILL_FALHA
echo  %RED%[ERRO]%RESET% Nao foi possivel encerrar %WHITE%"!PROC_NOME!"%RESET% %GRAY%(PID:%RESET% %CYAN%!PID!%RESET%%GRAY%)%RESET%.
echo         Tente executar o script como %YELLOW%Administrador%RESET%.
call :REGISTRAR_LOG "ERRO" "!PID!" "!PROC_NOME!"
call :REGISTRAR_SESSAO "ERRO" "!PID!" "!PROC_NOME!"
goto KILL_FIM

:KILL_FIM
set "PROC_NOME="
set "KILL_ERR="
echo.
pause
goto MENU

:: ============================================================
:HISTORICO
cls
echo %CYAN%  ╔══════════════════════════════════════════════════════╗%RESET%
echo %CYAN%  ║%BOLD%%WHITE%               HISTORICO DA SESSAO ATUAL              %RESET%%CYAN%║%RESET%
echo %CYAN%  ╠══════════════════════════════════════════════════════╣%RESET%
echo %CYAN%  ║%RESET%  %YELLOW%Usuario%RESET% : %WHITE%%USERNAME%%RESET%     %YELLOW%Maquina%RESET%: %WHITE%%COMPUTERNAME%%RESET%
echo %CYAN%  ║%RESET%  %YELLOW%Processos encerrados com sucesso%RESET%: %GREEN%%SESSAO_COUNT%%RESET%
echo %CYAN%  ╚══════════════════════════════════════════════════════╝%RESET%
echo.
echo  %YELLOW%Hora        Status   PID          Processo%RESET%
echo  %GRAY%─────────── ──────── ──────────── ────────────────────%RESET%

set ACOES=0
for /f "usebackq delims=" %%L in ("%SESSAO_TEMP%") do (
    echo  %%L
    set /a ACOES+=1
)

if %ACOES%==0 (
    echo  %GRAY%Nenhuma acao registrada nesta sessao ainda.%RESET%
)

echo.
echo  %GRAY%Log completo salvo em: %LOG_FILE%%RESET%
echo.
pause
goto MENU

:: ============================================================
:REGISTRAR_LOG
echo [%DATE% %TIME:~0,8%] USER:%USERNAME% ^| PC:%COMPUTERNAME% ^| STATUS:%~1 ^| PID:%~2 ^| PROC:%~3 >> "%LOG_FILE%"
goto :EOF

:REGISTRAR_SESSAO
echo [%TIME:~0,8%]  [%~1]  PID: %~2   ^|  Processo: %~3 >> "%SESSAO_TEMP%"
goto :EOF

:: ============================================================
:SAIR
cls
echo.
echo %CYAN%  ╔══════════════════════════════════════════════════════╗%RESET%
echo %CYAN%  ║%BOLD%%WHITE%                RESUMO FINAL DA SESSAO                %RESET%%CYAN%║%RESET%
echo %CYAN%  ╠══════════════════════════════════════════════════════╣%RESET%
echo %CYAN%  ║%RESET%  %YELLOW%Usuario%RESET% : %WHITE%%USERNAME%%RESET%
echo %CYAN%  ║%RESET%  %YELLOW%Maquina%RESET% : %WHITE%%COMPUTERNAME%%RESET%
echo %CYAN%  ║%RESET%  %YELLOW%Data/Hr%RESET% : %WHITE%%DATE% - %TIME:~0,8%%RESET%
echo %CYAN%  ║%RESET%  %YELLOW%Processos encerrados%RESET%: %GREEN%%SESSAO_COUNT%%RESET%
echo %CYAN%  ╚══════════════════════════════════════════════════════╝%RESET%
echo.

if %SESSAO_COUNT% gtr 0 (
    echo  %YELLOW%Acoes realizadas:%RESET%
    echo  %GRAY%──────────────────────────────────────────────────────%RESET%
    for /f "usebackq delims=" %%L in ("%SESSAO_TEMP%") do echo  %%L
    echo.
)

echo  %GRAY%Log salvo em: %LOG_FILE%%RESET%
echo.
if exist "%SESSAO_TEMP%" del "%SESSAO_TEMP%" > nul 2>&1
echo  %CYAN%Saindo... Ate logo,%RESET% %WHITE%%USERNAME%%RESET%%CYAN%!%RESET%
echo.
timeout /t 3 > nul
endlocal
exit