# Guia de Configuração: Sincronização Bidirecional Rclone (Ubuntu -> Google Drive)

Este documento detalha o passo a passo para criar uma pasta de trabalho local com sincronização offline/online usando o `rclone` e automatizada via `systemd`.

## 1. Instalação e Configuração Inicial
Instale o pacote no Ubuntu:
`sudo apt update && sudo apt install rclone`

Conecte a sua conta do Google Drive:
`rclone config`
*(Respostas do menu: `n` para New remote > Nome: `gdrive` > Storage: `drive` > Scope: `1` > Auto config: `y` > Faça login no navegador).*

## 2. Estrutura de Pastas e Primeira Sincronização
Crie a pasta local que servirá como espelho da nuvem:
`mkdir -p ~/GoogleDrive/Workspace`

Faça a primeira sincronização. **Atenção:** O parâmetro `--resync` deve ser usado APENAS nesta primeira vez (ou caso o banco de dados corrompa) para criar o mapeamento inicial:
`rclone bisync "gdrive:Workspace" ~/GoogleDrive/Workspace --resync -P`

## 3. Atalho Manual (Alias) para o Dia a Dia
Crie um atalho rápido para puxar as atualizações da nuvem antes de começar a trabalhar.

Abra o arquivo de configuração do terminal:
`nano ~/.bashrc`

Adicione a seguinte linha no final do arquivo:
`alias sync-drive='rclone bisync "gdrive:Workspace" ~/GoogleDrive/Workspace -P'`

Recarregue o terminal para aplicar:
`source ~/.bashrc`

## 4. Automação de Envio (Systemd)
O objetivo aqui é fazer o sistema enviar as alterações para a nuvem silenciosamente sempre que um arquivo for salvo/fechado na pasta local.

**Passo A: O Script de Execução**
Crie uma pasta oculta para guardar seus scripts e crie o arquivo:
`mkdir -p ~/.scripts`
`nano ~/.scripts/sync_rclone.sh`

Cole o código abaixo e salve:
#!/bin/bash
rclone bisync "gdrive:Workspace" "$HOME/GoogleDrive/Workspace"

Dê permissão de execução ao script:
`chmod +x ~/.scripts/sync_rclone.sh`

**Passo B: O "Olheiro" do Sistema (Path Unit)**
Crie o arquivo que vai monitorar a pasta:
`mkdir -p ~/.config/systemd/user`
`nano ~/.config/systemd/user/gdrive-sync.path`

Cole o código abaixo e salve:
[Unit]
Description=Monitora a pasta Workspace do Google Drive

[Path]
PathModified=%h/GoogleDrive/Workspace

[Install]
WantedBy=default.target

**Passo C: O Serviço (Service Unit)**
Crie o arquivo que conecta o gatilho ao seu script:
`nano ~/.config/systemd/user/gdrive-sync.service`

Cole o código abaixo e salve:
[Unit]
Description=Executa a sincronização do Rclone

[Service]
Type=oneshot
ExecStart=%h/.scripts/sync_rclone.sh

**Passo D: Ativar a Automação**
Recarregue o gerenciador do sistema e ligue o monitoramento:
`systemctl --user daemon-reload`
`systemctl --user enable --now gdrive-sync.path`

## 5. Resumo do Fluxo de Trabalho (Workflow)
* **Começando o dia:** Abra o terminal e digite `sync-drive` para baixar qualquer coisa que tenha sido alterada pelo celular/nuvem.
* **Durante o trabalho:** Apenas salve seus arquivos normalmente (`Ctrl+S`). O Systemd cuidará de subir as alterações para o Google Drive em segundo plano.