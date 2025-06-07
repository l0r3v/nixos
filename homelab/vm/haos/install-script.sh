set -e

virt-install \
    --name homeassistant\
    --description "Home Assistant OS" --os-variant=generic \
    --memory 3072 \
    --boot uefi \
    --disk /srv/archive/VMs/haos_ova-15.1.qcow2,bus=scsi --controller type=scsi,model=virtio-scsi --import\
    --vcpus=2 \
    --graphics none\
    --network network=macvtap-net\
    --check path_in_use=off
#virt-install --name haos --description "Home Assistant OS" --os-variant=generic --ram=4096 --vcpus=2 --disk <PATH TO QCOW2 FILE>,bus=scsi --controller type=scsi,model=virtio-scsi --import --graphics none --boot uefi
