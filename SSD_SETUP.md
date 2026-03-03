# Media SSD Setup Checklist

1. **Identify the New Disk**
   - Install the drive, then run `lsblk -f` or `sudo fdisk -l` to find the device path (`/dev/nvme1n1`, `/dev/sdb`, etc.). Double-check you’re targeting the right disk before formatting.

2. **Partition & Format**
   - Example for a single ext4 partition:
     ```bash
     sudo wipefs -fa /dev/nvme1n1
     sudo parted /dev/nvme1n1 -- mklabel gpt
     sudo parted /dev/nvme1n1 -- mkpart primary 0% 100%
     sudo mkfs.ext4 -L media /dev/nvme1n1p1
     ```
   - Swap the device names/fs type to match your hardware/preferences (btrfs/xfs work too).

3. **Mount Point**
   - Create the target path once: `sudo mkdir -p /srv/media` (this is the value of `services.homelab.mediaDir`).

4. **Declare the Filesystem**
   - Grab the UUID with `sudo blkid` and add to `hosts/server/hardware-configuration.nix`:
     ```nix
     fileSystems."/srv/media" = {
       device = "/dev/disk/by-uuid/<UUID>";
       fsType = "ext4";
       options = [ "nofail" ];
     };
     ```
   - Commit the change so future installs know about the disk.

5. **Copy Existing Data (Optional)**
   - If `/srv/media` already has content, sync it to the SSD before switching:
     ```bash
     sudo mount /dev/disk/by-uuid/<UUID> /mnt
     sudo rsync -aHAX /srv/media/ /mnt/
     sudo umount /mnt
     ```

6. **Rebuild**
   - Run `sudo nixos-rebuild switch --flake .#server` (locally or via `--target-host`) so the new filesystem mounts and all services restart against it.

Once mounted at `/srv/media`, Jellyfin, Syncthing, Immich, the *arr stack, Audiobookshelf, and the Calibre container automatically use the SSD without further tweaks.
