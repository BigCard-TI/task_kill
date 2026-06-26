# 🔫 Gerenciador de Processos — killer.bat

Script Windows Batch para visualizar, filtrar e encerrar processos em execução via linha de comando, com interface colorida via ANSI, confirmação de segurança e registro completo de auditoria em log.

Sem dependências externas — utiliza apenas recursos nativos do Windows (`tasklist`, `taskkill`, `cmd.exe`).

---

## Como Executar

```batch
:: Clique com o botão direito → Executar como Administrador
killer.bat
```

> **Recomendado rodar como Administrador** para ter permissão total sobre todos os processos, incluindo os de outros usuários e de sistema.

---

## Menu Principal

```
╔══════════════════════════════════════════════════════╗
║          GERENCIADOR DE PROCESSOS - TI               ║
╠══════════════════════════════════════════════════════╣
║  [1]  Listar TODOS os processos                      ║
║  [2]  Filtrar processos por nome                     ║
║  [3]  Ver histórico da sessão                        ║
║  [0]  Sair                                           ║
╚══════════════════════════════════════════════════════╝
```

| Opção | Ação |
|---|---|
| `1` | Lista todos os processos em execução via `tasklist` |
| `2` | Filtra processos por nome parcial (ex: `chrome`, `java`) |
| `3` | Exibe ações realizadas na sessão atual |
| `0` | Mostra resumo final e encerra com limpeza |

---

## Fluxo de Encerramento de Processo

Após listar ou filtrar, o script solicita o PID e segue este fluxo:

1. **Validação** — verifica se o PID é um número válido
2. **Identificação** — consulta o nome do processo pelo PID
3. **Confirmação** — exibe nome e PID e pede `[S/N]`
4. **Execução** — `taskkill /F /PID` com encerramento forçado
5. **Registro** — grava o resultado no log de sessão e no arquivo persistente

---

## Logs

| Tipo | Local | Formato |
|---|---|---|
| Persistente | `C:\Logs\GerenciadorProcessos\processos_<MAQUINA>.log` | `[DATA HORA] USER:<u> \| PC:<pc> \| STATUS:<s> \| PID:<p> \| PROC:<nome>` |
| Sessão (temporário) | `%TEMP%\gp_sessao_<RANDOM>.tmp` | `[HH:MM:SS] [STATUS] PID: <p> \| Processo: <nome>` |

> Se `C:\Logs\GerenciadorProcessos` não puder ser criado por falta de permissão, o log persistente é salvo automaticamente em `%TEMP%`.
> O arquivo de sessão é apagado automaticamente ao sair.

---

## Requisitos

- Windows 10 (build 1511+) ou Windows 11
- Suporte a ANSI no terminal (nativo nas versões acima)
- Sem instalação ou dependências externas
