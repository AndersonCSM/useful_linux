# Fix: Superaquecimento durante Suspensão no ASUS TUF F16 (Ubuntu)

> **Modelo testado:** ASUS TUF Gaming F16 (FX608JHR)  
> **Distribuição:** Ubuntu (kernel 6.17+)  
> **GPU:** NVIDIA RTX 5050 + Intel Raptor Lake UHD  
> **BIOS:** FX608JHR.309  

---

## O Problema

Ao suspender o notebook (fechar a tampa ou usar `systemctl suspend`), o sistema aparentava estar suspenso — tela apagada, ventoinhas paradas — mas o hardware continuava **completamente ativo e aquecendo**.

Em cenários críticos, o notebook podia ser guardado na mochila nesse estado e atingir temperaturas perigosas sem nenhum resfriamento ativo.

---

## Causa Raiz

O sistema entrava corretamente em suspensão S3 (deep sleep), mas o controlador **XHCI (USB)** gerava um evento que acordava o hardware parcialmente. Nesse estado intermediário:

- A tela permanecia apagada
- As ventoinhas paravam (controle térmico não era restaurado)
- CPU e GPU continuavam ativas e aquecendo
- O sistema não respondia a interações normais

Evidência nos logs do kernel:

```bash
xhci_hcd 0000:38:00.0: xHC error in resume, USBSTS 0x401, Reinit
```

Esse erro indica que o controlador USB/Thunderbolt (`Intel Device 1135`) acordava durante a suspensão e falhava ao reinicializar, colocando o sistema num estado híbrido indesejado.

---

## Configuração do Sistema (referência)

| Item | Valor |
| ------ | ------- |
| Kernel | 6.17.0-23-generic |
| BIOS | FX608JHR.309 |
| Driver NVIDIA | 595.58.03 |
| Modo de suspensão | S3 (deep) |
| GPU discreta | NVIDIA RTX 5050 (00:01:00.0) |
| GPU integrada | Intel Raptor Lake UHD (00:02.0) |
| Controlador USB principal | 0000:00:14.0 |
| Controlador Thunderbolt/USB-C | 0000:38:00.0 |

---

## Solução Aplicada

A solução consiste em três partes:

1. **Garantir suspensão S3 real** via parâmetros do GRUB
2. **Desabilitar wakeup sources USB** antes de suspender via hook do systemd
3. **Configurar a NVIDIA** para preservar memória durante suspensão

---

## Passo a Passo

### Passo 1 — Verificar o modo de suspensão atual

```bash
cat /sys/power/mem_sleep
```

A saída deve mostrar `[deep]` entre colchetes. Se mostrar `[s2idle]`, o passo 2 é obrigatório.

---

### Passo 2 — Configurar parâmetros do GRUB

Edite o arquivo de configuração do GRUB:

```bash
sudo nano /etc/default/grub
```

Localize a linha `GRUB_CMDLINE_LINUX_DEFAULT` e adicione os parâmetros:

```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash acpi_osi=Linux pcie_aspm=off mem_sleep_default=deep usbcore.autosuspend=-1"
```

**O que cada parâmetro faz:**

> - `acpi_osi=Linux` — informa ao firmware que o sistema é Linux, melhorando compatibilidade ACPI
> - `pcie_aspm=off` — desabilita gerenciamento de energia PCIe agressivo que pode causar instabilidade
> - `mem_sleep_default=deep` — força suspensão S3 (deep sleep) como padrão
> - `usbcore.autosuspend=-1` — desabilita autosuspend USB que pode causar wakeups indesejados

Aplique as mudanças:

```bash
sudo update-grub
```

---

### Passo 3 — Criar hook de suspensão para controle dos wakeup sources

Crie o script de hook:

```bash
sudo tee /usr/lib/systemd/system-sleep/fix-xhci.sh << 'EOF'
#!/bin/bash
# Fix: Desabilita wakeup sources USB antes de suspender
# Evita que controladores XHCI acordem o sistema parcialmente
# causando superaquecimento com ventoinhas paradas
#
# Argumentos systemd: $1 = pre/post, $2 = suspend/hibernate/hybrid-sleep

case "$1/$2" in
  pre/suspend|pre/hybrid-sleep)
    # Desabilita wakeup em todos os controladores PCI
    for dev in /sys/bus/pci/devices/*/power/wakeup; do
      echo disabled > "$dev" 2>/dev/null
    done
    ;;
  post/suspend|post/hybrid-sleep)
    # Reabilita apenas o controlador USB principal após acordar
    # Ajuste o endereço abaixo para o seu sistema se necessário
    echo enabled > /sys/bus/pci/devices/0000:00:14.0/power/wakeup 2>/dev/null
    ;;
esac
EOF
```

Dê permissão de execução:

```bash
sudo chmod +x /usr/lib/systemd/system-sleep/fix-xhci.sh
```

> **Atenção:** Não adicione `modprobe -r` para remover módulos de rede nesse script. Remover módulos durante o processo de suspensão pode causar kernel panic e desligamento forçado.

---

### Passo 4 — Configurar a NVIDIA para preservar memória na suspensão

```bash
sudo tee /etc/modprobe.d/nvidia-power.conf << 'EOF'
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=/var/tmp
EOF
```

Atualize o initramfs:

```bash
sudo update-initramfs -u
```

---

### Passo 5 — Garantir que os serviços NVIDIA estão habilitados

```bash
sudo systemctl enable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service
```

---

### Passo 6 — Reiniciar e verificar

```bash
sudo reboot
```

Após reiniciar, confirme o modo de suspensão:

```bash
cat /sys/power/mem_sleep
# Esperado: s2idle [deep]
```

Teste a suspensão:

```bash
systemctl suspend
```

Após acordar, verifique as ventoinhas:

```bash
sensors | grep -i fan
# Esperado: cpu_fan e gpu_fan com RPM > 0
```

---

## Como verificar os logs após suspensão

```bash
journalctl -b 0 | grep -i -E "suspend|resume|fan|thermal|xhci" | tail -40
```

**Saída esperada (sistema saudável):**

```bash
kernel: PM: suspend entry (deep)
kernel: PM: suspend exit
systemd-sleep: System returned from sleep operation 'suspend'.
```

**O erro abaixo é cosmético e pode ser ignorado** — é um bug do driver do Thunderbolt Intel e não afeta o funcionamento:

```bash
xhci_hcd 0000:38:00.0: xHC error in resume, USBSTS 0x401, Reinit
```

---

## 🗺️ Mapa dos controladores USB (referência para o FX608JHR)

```bash
0000:00:14.0  →  usb1 (480M)   Mouse, teclado, webcam, Bluetooth
              →  usb2 (20Gbps)
0000:38:00.0  →  usb3 (480M)   Thunderbolt / USB-C PD
              →  usb4 (10Gbps)
```

> Se quiser usar **carregamento via USB-C PD** durante a suspensão, o controlador `0000:38:00.0` precisa permanecer com wakeup habilitado. Nesse caso, modifique o hook para desabilitar apenas o `0000:00:14.0`.

---

## Arquivos modificados — resumo

| Arquivo | Finalidade |
| --------- | ----------- |
| `/etc/default/grub` | Parâmetros de boot do kernel |
| `/usr/lib/systemd/system-sleep/fix-xhci.sh` | Hook de suspensão para controle dos wakeup sources |
| `/etc/modprobe.d/nvidia-power.conf` | Configuração da NVIDIA para suspensão |

---

## 🩺 Diagnóstico rápido (para outros usuários)

Se você suspeita do mesmo problema, rode:

```bash
# 1. Verificar modo de suspensão
cat /sys/power/mem_sleep

# 2. Ver wakeup sources habilitados
cat /proc/acpi/wakeup | grep enabled

# 3. Verificar fans após acordar
sensors | grep -i fan

# 4. Ver logs da última suspensão
journalctl -b 0 | grep -i -E "suspend|resume|xhci|error" | tail -30

# 5. Identificar controladores USB do sistema
lspci | grep -i usb
ls /sys/bus/pci/devices/*/usb*/
```

---

## ℹNotas adicionais

- O erro `ucsi_acpi USBC000:00: failed to re-enable notifications (-110)` é um bug conhecido do UCSI no Thunderbolt e não tem impacto no funcionamento
- O erro `NVML is missing` do LACT daemon após o resume é cosmético — a GPU funciona normalmente
- O erro `ACPI Error: No installed handler for fixed event - PowerButton` é inofensivo
- O LED de energia do TUF F16 pisca lentamente (modo respiração) quando o S3 está ativo corretamente — use isso como indicador visual antes de guardar na mochila

---

Testado em maio de 2026 · ASUS TUF Gaming F16 FX608JHR · Ubuntu · Kernel 6.17
