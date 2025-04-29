
alias zero='
    echo "[+] SELECIONE O DISCO (ex: /dev/sda):";
    read -r DISK;
    echo "[⚠️] VOCÊ ESTÁ PRESTES A DESTRUIR TODOS OS DADOS EM ${DISK}";
    read -p "CONFIRME COM 'SACRIFÍCIO': " confirm;
    if [[ "$confirm" != "SACRIFÍCIO" ]]; then
        echo "[✖] OPERAÇÃO CANCELADA.";
        return 1;
    fi;
    echo "[🔥] ZERANDO ${DISK}... (DEMORA ≈10s-5min)";
    sudo wipefs -a "$DISK";           # 1ª Camada: Remove assinaturas
    sudo sgdisk --zap-all "$DISK"; # 2ª Camada: Apaga tabela de partições
    sudo dd if=/dev/zero of="$DISK" bs=1M count=1024 status=progress; # 3ª Camada: Zera setores críticos
    sudo blkdiscard "$DISK";       # 4ª Camada (SSDs): TRIM agressivo
    sync;                                          # Garante descarga de buffers
    sudo partprobe "$DISK";                        # Recarrega tabela de partições
    echo "[✓] DISCO ${DISK} FOI TRANSFORMADO EM PÓ CÓSMICO."
'
