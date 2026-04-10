# THE COMPLETE WORKING GUIDE:
Windows/Linux/Debian on macOS via External NVMe VM (Bare-Metal Virtualized)

Battle-tested and 100% verified to work

---

## CRITICAL SECURITY NOTICE

This setup requires SIP to be DISABLED during use. This will temporarilly reduces your Mac's security posture.

Do not proceed unless you understand the risks and have implemented proper network isolation.

---

## TABLE OF CONTENTS

1. Prerequisites
2. Prepare the Disk
3. SIP Handling (CRITICAL)
4. Create Raw Disk VMDK
5. Create and Configure the VM
6. Suggestions
7. Final Notes

---

## PART 1: Prerequisites

- External NVMe drive with working Debian installation (encrypted LVM optional)
- VirtualBox installed (latest version recommended)
- macOS (Intel or Apple Silicon)
- Understanding that SIP will remain DISABLED
- Network isolation plan (see Part 6)
- Backup of all important data

---

## PART 2: Prepare the Disk

```bash
# 1. Identify your external NVMe drive
diskutil list

# 2. Get detailed info to confirm correct disk
diskutil info /dev/diskX | grep -E "Device Node|Whole|Size|Media Name|Protocol"

# 3. CRITICAL: Ensure NO APFS containers exist on this disk!
diskutil apfs list | grep -A 5 "diskX"

# If you see APFS containers, you MUST remove them ALL:
#   sudo diskutil apfs deleteContainer /dev/diskXsY
#   (Repeat for EVERY APFS container on this disk)

# 4. After removing APFS, verify the disk is clean
diskutil list diskX

# 5. UNMOUNT the drive (DO NOT eject)
diskutil unmountDisk force /dev/diskX

# 6. Verify it's unmounted
diskutil info /dev/diskX | grep "Mounted"
# Should show: Mounted: Not applicable (no file system)
```

---

## PART 3: SIP Handling (CRITICAL - MUST REMAIN DISABLED)

SIP must stay DISABLED for the VM to function.

### Step 3.1: Disable SIP (Permanent)

```bash
# 1. Reboot into Recovery Mode
# Intel Mac: Restart and hold Cmd+R immediately
# Apple Silicon: Restart and hold power button

# 2. Once in Recovery Mode, open Terminal from Utilities menu

# 3. Disable SIP
csrutil disable

# 4. You should see: "Successfully disabled System Integrity Protection"

# 5. Reboot normally
reboot

# 6. Verify SIP is disabled
csrutil status
# Should show: System Integrity Protection status: disabled
```

### Step 3.2: Verify SIP Status (After Every Reboot)

```bash
# Check before using the VM
csrutil status

# If it shows "enabled", the VM will fail with VERR_RESOURCE_BUSY
# You must reboot to Recovery Mode and disable it again
```

### Why SIP Must Remain Disabled

| SIP Status | Raw Disk VMDK | VirtualBox with sudo | Result |
|------------|---------------|---------------------|--------|
| Enabled | Created but locked | Works but can't access disk | VERR_RESOURCE_BUSY |
| Disabled | Works perfectly | Works perfectly | Success |

This is a known limitation. VirtualBox's raw disk access requires SIP to be disabled on macOS. The sudo elevation is not sufficient.

---

## PART 4: Create Raw Disk VMDK

Create your raw disk VMDK with SIP disabled.

```bash
# 1. Make sure disk is still unmounted
diskutil unmountDisk force /dev/diskX

# 2. Use the LEGACY command (it's deprecated but it WORKS)
sudo VBoxManage internalcommands createrawvmdk \
  -filename "/Users/$(whoami)/VirtualBox VMs/debian.vmdk" \
  -rawdisk /dev/diskX

# 3. Set proper permissions
sudo chown $(whoami) "/Users/$(whoami)/VirtualBox VMs/debian.vmdk"
chmod 644 "/Users/$(whoami)/VirtualBox VMs/debian.vmdk"

# 4. Verify the VMDK was created
ls -la "/Users/$(whoami)/VirtualBox VMs/debian.vmdk"
cat "/Users/$(whoami)/VirtualBox VMs/debian.vmdk"
```

---

## PART 5: Create and Configure the VM

```bash
# Start VirtualBox with sudo
sudo /Applications/VirtualBox.app/Contents/MacOS/VirtualBox
```

### In VirtualBox GUI:

#### Create New VM:

| Field | Value |
|-------|-------|
| Name | Debian-Linux |
| Type | Linux |
| Version | Debian (64-bit) |
| Memory | 4096 MB |
| Hard disk | Use an existing virtual hard disk file -> Select debian.vmdk |

#### VM Settings:

System -> Motherboard:
- Enable EFI (checked)
- Boot Order: Hard Disk first
- Chipset: PIIX3

System -> Processor: At least 2 CPUs

Network -> Adapter 1:
- Attached to: Internal Network (for isolation - see Part 14)
- Name: isolated_net
- Promiscuous Mode: Deny

USB: Keep DISABLED

## PART 6: Suggestions

1. SIP must remain DISABLED - This is non-negotiable for raw disk access
2. Network isolation is HIGHLY recommended - Never use bridged or NAT with SIP disabled
3. APFS containers will cause VERR_RESOURCE_BUSY - Remove them ALL before starting
4. Legacy internalcommands createrawvmdk works better than modern createmedium for raw disks
5. VirtualBox must run with sudo for raw disk access
6. Consider the host-side attachment and enabling of a usb 3.0 WiFi adapter to the virtual machine, and disabling the virtual machine's network adapter entirely, instead relying on the external adapter for internet entirely:
    In VirtualBox VM Settings -> USB:
     - Enable USB 3.0 controller
     - Add a USB WiFi or Ethernet adapter
     - Install within virtual machine, reboot, wirelessly connect to your local network via usb 3.0 WiFi adapter, not NAT etc.

Result: VM gets its own network hardware, completely separate from macOS.

### Mitigation 4: Read-only Shared Folders, No Clipboard

In VirtualBox VM Settings:
- General -> Advanced: Shared Clipboard = Disabled
- General -> Advanced: Drag'n'Drop = Disabled
- Shared Folders: Read-only

---

## FINAL NOTES

You now have a fully functional Debian VM on external NVMe with:

- Raw disk performance
- SIP disabled (required)
- Network isolation implemented

This setup enables true simultaneous booting of two operating systems - your host macOS and the guest Debian on the external NVMe drive, far surpassing the limitations of dual booting.

Proceed with awareness, not fear. Security is about informed risk management.
