{inputs, ...}: let
  nixvirt = inputs.nixvirt;
in {
  # Blacklist driver host per i device passati alla VM
  boot.blacklistedKernelModules = ["ax88179_178a" "cdc_ncm"];
  networking.networkmanager.unmanaged = ["mac:08:26:ae:3a:ef:0e"];

  virtualisation.libvirt = {
    enable = true;
    connections."qemu:///system" = {
      domains = [
        {
          active = true;
          definition = nixvirt.lib.domain.writeXML {
            type = "kvm";
            name = "homeassistant";
            uuid = "2ab0e553-ae34-47ac-9b04-5997d3783670";
            description = "Home Assistant OS";
            features = {
              acpi = {};
              apic = {};
            };
            memory = {
              count = 3145728;
              unit = "KiB";
            };

            vcpu = {
              count = 2;
              placement = "static";
            };

            os = {
              firmware = "efi";
              arch = "x86_64";
              machine = "pc-i440fx-10.2";
              type = "hvm";
              boot = [{dev = "hd";}];
            };

            cpu = {
              mode = "host-passthrough";
              check = "none";
              migratable = true;
            };

            clock = {
              offset = "utc";
              timer = [
                {
                  name = "rtc";
                  tickpolicy = "catchup";
                }
                {
                  name = "pit";
                  tickpolicy = "delay";
                }
                {
                  name = "hpet";
                  present = false;
                }
              ];
            };

            on_poweroff = "destroy";
            on_reboot = "restart";
            on_crash = "destroy";

            pm = {
              suspend-to-mem = {enabled = false;};
              suspend-to-disk = {enabled = false;};
            };

            devices = {
              emulator = "/run/libvirt/nix-emulators/qemu-system-x86_64";

              disk = [
                {
                  type = "file";
                  device = "disk";
                  driver = {
                    name = "qemu";
                    type = "qcow2";
                  };
                  source = {
                    file = "/srv/archive/VMs/haos_ova-15.1.qcow2";
                    index = 1;
                  };
                  target = {
                    dev = "sda";
                    bus = "scsi";
                  };
                }
              ];

              controller = [
                {
                  type = "scsi";
                  index = 0;
                  model = "virtio-scsi";
                }
                {
                  type = "usb";
                  index = 0;
                  model = "ich9-ehci1";
                }
                {
                  type = "usb";
                  index = 0;
                  model = "ich9-uhci1";
                  master = {startport = 0;};
                }
                {
                  type = "usb";
                  index = 0;
                  model = "ich9-uhci2";
                  master = {startport = 2;};
                }
                {
                  type = "usb";
                  index = 0;
                  model = "ich9-uhci3";
                  master = {startport = 4;};
                }
                {
                  type = "pci";
                  index = 0;
                  model = "pci-root";
                }
              ];

              serial = [
                {
                  type = "pty";
                  target = {
                    type = "isa-serial";
                    port = 0;
                  };
                }
              ];

              console = [
                {
                  type = "pty";
                  target = {
                    type = "serial";
                    port = 0;
                  };
                }
              ];

              input = [
                {
                  type = "mouse";
                  bus = "ps2";
                }
                {
                  type = "keyboard";
                  bus = "ps2";
                }
              ];

              hostdev = [
                {
                  mode = "subsystem";
                  type = "usb";
                  managed = true;
                  source = {
                    vendor = {id = 4292;};
                    product = {id = 60000;};
                  };
                }
                {
                  mode = "subsystem";
                  type = "usb";
                  managed = true;
                  source = {
                    vendor = {id = 2965;};
                    product = {id = 6032;};
                  };
                }
              ];

              memballoon = {
                model = "virtio";
              };
            };
          };
        }
      ];
    };
  };
}
