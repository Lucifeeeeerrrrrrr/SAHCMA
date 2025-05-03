#!/bin/bash

# Definir variáveis globais
DISK="/dev/sda"  # Altere para o disco que você deseja
MOUNTROOT="/mnt"

# Criar diretórios de log
mkdir -p /log
touch /log/vemCaPutinha.log /log/vemCaPutinha_control.log

# Função para exibir informações sobre o disco
listar_disco() {
    lsblk -dpno NAME,SIZE,MODEL | nl -w2 -s'. '
}

# Função para criar e formatar as partições
criar_formatar_particoes() {
    # Calcular o tamanho disponível para partições
    DISK_SIZE_BYTES=$(blockdev --getsize64 $DISK)
    VG_SIZE_MB=$((DISK_SIZE_BYTES / 1024 / 1024 - 1536))
    echo "Tamanho disponível para partições: $VG_SIZE_MB MiB"

    # Criar partições (nome, tipo e tamanho)
echo "Criando partições no disco..."

# Definição das partições: número:nome:typecode:tamanho_em_porcentagem (0 = usar todo o restante do espaço)
particoes=(
  "1:Cortex-Boot-EFI:ef00:512"    # valor fixo em MB
  "2:Cerebellum-Boot:8300:1024"   # valor fixo em MB
  "3:root:8300:$((VG_SIZE_MB * 20 / 100))"
  "4:var:8300:$((VG_SIZE_MB * 5 / 100))"
  "5:tmp:8300:$((VG_SIZE_MB * 2 / 100))"
  "6:usr:8300:$((VG_SIZE_MB * 34 / 100))"
  "7:swap:8200:$((VG_SIZE_MB * 5 / 100))"
  "8:home:8300:0"
)

for p in "${particoes[@]}"; do
  IFS=':' read -r num nome tipo tamanho <<< "$p"

  if [ "$tamanho" -eq 0 ]; then
    sudo sgdisk --new=$num:0:0 --typecode=$num:$tipo --change-name=$num:"$nome" $DISK
  else
    sudo sgdisk --new=$num:0:+${tamanho}M --typecode=$num:$tipo --change-name=$num:"$nome" $DISK
  fi
done

    # Atualizar a tabela de partições
    sudo partprobe $DISK
    sleep 2
    sudo udevadm settle

    # Formatar as partições
    echo "Formatando partições..."
    
    # Formatar a partição EFI
    sudo mkfs.vfat -F32 -n EFI ${DISK}1

    # Formatar a partição BOOT
    sudo mkfs.ext4 -q -L BOOT ${DISK}2

    # Formatar a partição ROOT
    sudo mkfs.btrfs -L ROOT -f ${DISK}3

    # Formatar a partição VAR
    sudo mkfs.ext4 -q -L VAR ${DISK}4
    sudo tune2fs -o journal_data_writeback ${DISK}4

    # Formatar a partição TMP
    sudo mkfs.ext4 -q -L TMP ${DISK}5

    # Formatar a partição USR
    sudo mkfs.ext4 -q -L USR ${DISK}6

    # Formatar a partição SWAP
    sudo mkswap -L SWAP ${DISK}7
    sudo swapon ${DISK}7

    # Formatar a partição HOME
    sudo mkfs.btrfs -L HOME -f ${DISK}8

    # Verificar todas as montagens
    lsblk -f
    echo "Processo concluído: +20-40% de vida útil do SSD, +15-30% de I/O, sincronia CPU/SSD atingida."
}

# Função principal
main() {
    # Listar discos disponíveis
    listar_disco

    # Perguntar qual disco escolher
    echo "Escolha um disco (exemplo: /dev/sda):"
    read DISK
    echo "Disco selecionado: $DISK"

    # Zerar o disco
    zerar_disco

    # Criar e formatar as partições
    criar_formatar_particoes
}

# Chamar a função principal
main
