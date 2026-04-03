# Relatório de Configuração Técnica: Asus TUF Gaming no Ubuntu 24.04

Este documento serve como um guia de referência para as configurações de hardware e energia realizadas no notebook Asus TUF F16, visando otimizar a vida útil da bateria, o controle térmico e a estabilidade do sistema em ambiente Linux (Ubuntu 24.04 Noble).

---

## 1. Correção Crítica: Suspensão do Sistema (Driver NVIDIA)
O problema de o notebook não acordar, ou travar em tela preta ao suspender, era causado pela falha do driver NVIDIA em preservar a memória de vídeo.

**Ações realizadas:**

1. Habilitação dos serviços de orquestração do systemd:

```bash
sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service
```

2. Forçar preservação de alocação de memória (VRAM):

Criação do arquivo `/etc/modprobe.d/nvidia-power-management.conf` com o parâmetro:

```conf
options nvidia NVreg_PreserveVideoMemoryAllocations=1
```

3. Atualização da imagem de inicialização:

```bash
sudo update-initramfs -u
```

## 2. Implementação do Ecossistema Asus-Linux

Para substituir o Armoury Crate do Windows, foram instalados `asusctl` e `supergfxctl`.
Devido à versão do Ubuntu (24.04), os pacotes foram compilados via Docker a partir do repositório da comunidade.

**Serviços ativos:**

- `asusd`: gerencia perfis, ventoinhas e limites de carga.
- `supergfxd`: gerencia a troca entre GPU integrada e dedicada (NVIDIA).

Comando de inicialização manual (se necessário):

```bash
sudo systemctl enable --now asusd supergfxd
```

## 3. Gestão de Conflitos: Power Profiles Daemon

O Ubuntu possui um gerenciador de energia genérico que conflita com as tabelas ACPI da Asus.
Ele foi desativado para permitir que o `asusd` controle o hardware sem interferências.

**Ação:**

```bash
sudo systemctl disable --now power-profiles-daemon
```

## 4. Controle Térmico e Curvas de Ventoinha (Fan Curves)

O perfil `Balanced` foi configurado para operar de forma silenciosa, mantendo as ventoinhas desligadas ou em baixa rotação até que a temperatura exija refrigeração ativa.

**Curva injetada (CPU e GPU):**

- 30°C - 40°C: 0% (silêncio total)
- 50°C: 10% (~1200 RPM)
- 60°C: 20% (~2400 RPM)
- 70°C: 35%
- 80°C: 50%
- 100°C: 95% (segurança máxima)

Comandos para reaplicação:

```bash
# Ativar e configurar
asusctl fan-curve --mod-profile Balanced --enable-fan-curves true
asusctl fan-curve --mod-profile Balanced --fan cpu --data "30c:0%,40c:0%,50c:10%,60c:20%,70c:35%,80c:50%,90c:80%,100c:95%"
asusctl fan-curve --mod-profile Balanced --fan gpu --data "30c:0%,40c:0%,50c:10%,60c:20%,70c:35%,80c:50%,90c:80%,100c:95%"

# Ativar flags individuais
asusctl fan-curve --mod-profile Balanced --fan cpu --enable-fan-curve true
asusctl fan-curve --mod-profile Balanced --fan gpu --enable-fan-curve true
asusctl profile set Balanced
```

## 5. Saúde da Bateria (Battery Health)

Para evitar desgaste químico prematuro, o limite de carga foi definido para 80%, ideal para uso contínuo na tomada.

Comandos:

- Setar limite: `asusctl battery limit 80`
- Carga total temporária: `asusctl battery oneshot` (carrega 100% apenas uma vez)
- Verificar status: `asusctl battery info`

## 6. Guia Rápido de Comandos (Cheat Sheet)

| Objetivo | Comando |
|---|---|
| Alternar perfil de energia | `asusctl profile next` |
| Monitorar temperatura/ventoinhas | `watch -n 1 sensors` |
| Modo economia extrema | `supergfxctl -m integrated` |
| Modo híbrido (jogos/render) | `supergfxctl -m hybrid` |
| Consultar curvas ativas | `asusctl fan-curve --mod-profile Balanced` |
