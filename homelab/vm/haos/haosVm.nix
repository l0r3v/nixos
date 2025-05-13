{inputs, ...}: let
  nixvirt = inputs.nixvirt;
in {
  virtualisation = {
    libvirt = {
      enable = true;
      connections."qemu:///system" = {
        domains = [
          {
            definition =
              #./haosVm.nix;
              nixvirt.lib.domain.writeXML (nixvirt.lib.domain.templates.linux
                {
                  name = "haos";
                  uuid = "caf372dc-6964-4c9b-b60c-ca567f386df7";
                  memory = {
                    count = 2;
                    unit = "GiB";
                  };
                  storage_vol = /home/hspasqui/archive/VMs/haos_ova-15.1.qcow2;
                  nvram_path = /var/lib/libvirt/qemu/nvram/haos_VARS.fd;
                  virtio_net = true;
                  virtio_drive = true;
                  install_virtio = true;
                });
            active = true;
          }
        ];
        networks = [
          {
            definition = ./macvtap.xml;
            active = true;
          }
        ];
      };
    };
  };
}
