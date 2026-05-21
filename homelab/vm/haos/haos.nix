{inputs, ...}: let
  nixvirt = inputs.nixvirt;
in {
  # Blacklist driver host per i device passati alla VM
  boot.blacklistedKernelModules = ["ax88179_178a" "cdc_ncm"];

  virtualisation.libvirt.connections."qemu:///system" = {
    domains = [
      {
        active = true;
        definition = nixvirt.lib.domain.writeXML {
          name = "homeassistant";
          uuid = "2ab0e553-ae34-47ac-9b04-5997d3783670";
          description = "Home Assistant OS";
          memory = {
            count = 3145728;
            unit = "KiB";
          };
          vcpu = 2;
          cpu.mode = "host-passthrough";

          os = {
            firmware = "efi";
            type = {
              arch = "x86_64";
              machine = "pc-i440fx-10.2";
              content = "hvm";
            };
            firmware_features = [
              {
                name = "enrolled-keys";
                enabled = false;
              }
              {
                name = "secure-boot";
                enabled = false;
              }
            ];
            boot = [{dev = "hd";}];
          };

          features = {
            acpi = {};
            apic = {};
          };

          clock = {
            offset = "utc";
            timers = [
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
            suspend-to-mem.enabled = false;
            suspend-to-disk.enabled = false;
          };

          devices = {
            disks = [
              {
                type = "file";
                device = "disk";
                driver = {
                  name = "qemu";
                  type = "qcow2";
                };
                source.file = "/srv/archive/VMs/haos_ova-15.1.qcow2";
                target = {
                  dev = "sda";
                  bus = "scsi";
                };
              }
            ];

            controllers = [
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
                master.startport = 0;
              }
              {
                type = "usb";
                index = 0;
                model = "ich9-uhci2";
                master.startport = 2;
              }
              {
                type = "usb";
                index = 0;
                model = "ich9-uhci3";
                master.startport = 4;
              }
            ];

            hostdevs = [
              {
                mode = "subsystem";
                type = "usb";
                managed = true;
                source.usb = {
                  vendor.id = "0x10c4";
                  product.id = "0xea60";
                };
              }
              {
                mode = "subsystem";
                type = "usb";
                managed = true;
                source.usb = {
                  vendor.id = "0x0b95";
                  product.id = "0x1790";
                };
              }
            ];

            serials = [
              {
                type = "pty";
                target.port = 0;
              }
            ];
            consoles = [
              {
                type = "pty";
                target.port = 0;
              }
            ];

            memballoon.model = "virtio";
          };
        };
      }
    ];
  };
}
