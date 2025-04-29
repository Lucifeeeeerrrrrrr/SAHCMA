get_uuid() {
    blkid -s UUID -o value "$1"
}

DISK="/dev/sda"
    cat <<EOF > /etc/fstab
# /etc/fstab - Gerado automaticamente

UUID=$(get_uuid ${DISK}3)   /               btrfs   defaults,noatime,compress=zstd,commit=120,ssd,space_cache=v2,autodefrag  0 1
UUID=$(get_uuid ${DISK}1)   /boot/efi       vfat    defaults,noatime,uid=0,gid=0,umask=0077,shortname=winnt                 0 1
UUID=$(get_uuid ${DISK}2)   /boot           ext4    defaults,noatime,errors=remount-ro                                     0 1
UUID=$(get_uuid ${DISK}8)   /home           btrfs   defaults,noatime,compress=zstd,commit=60,ssd,space_cache=v2,autodefrag  0 2
UUID=$(get_uuid ${DISK}6)   /usr            ext4    noatime,errors=remount-ro,commit=120                                 0 1
UUID=$(get_uuid ${DISK}4)   /var            ext4    defaults,noatime,data=journal,commit=30                                 0 2
UUID=$(get_uuid ${DISK}5)   /tmp            ext4    defaults,noatime,nosuid,nodev,commit=15                                 0 2
UUID=$(get_uuid ${DISK}7)   none            swap    sw                                                                     0 0
