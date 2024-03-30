# VBoxManage-createmedium
commands to use external disks as host-side space saving storage mediums with virtualbox in MacOS

Preparation

    Backup Important Data: Before proceeding, ensure you have backups of any important data on the external NVMe drive.

    Identify the NVMe Drive:
        Connect your external NVMe drive to your Mac.
        Open Terminal and run diskutil list to list all storage devices. Identify your external NVMe drive (look for something like /dev/disk2 or /dev/disk3).

    Unmount the NVMe Drive:
        In Terminal, unmount the NVMe drive using the command diskutil unmountDisk /dev/diskX, replacing /dev/diskX with the correct identifier of your drive.

Creating the VMDK File

    Create VMDK File:

        In Terminal, run the following command to create a VMDK file that points to your NVMe drive:

        css

        sudo VBoxManage createmedium disk --filename /path/to/your.vmdk --rawdisk /dev/diskX

        Replace /path/to/your.vmdk with the desired path and filename for the VMDK file. Replace /dev/diskX with your drive's identifier.

    Set Proper Permissions:
        Make sure that the created VMDK file is accessible. Adjust the file permissions if necessary.

Setting Up the Virtual Machine

    Open VirtualBox:
        Launch VirtualBox on your Mac.

    Create a New VM:
        Click on "New" to start creating a new virtual machine.
        Follow the VM creation wizard. Name your VM and select the type and version that match Debian.
        When prompted to add a hard disk, select "Use an existing virtual hard disk file." Click the folder icon to browse and select the VMDK file you created.

    Adjust VM Settings:
        Before starting the VM, go to its settings.
        Under "System" -> "Motherboard," ensure EFI is enabled if Debian uses UEFI.
        Configure other settings (like RAM, CPU) according to your preference.

Booting and Using the VM

    Start the VM:
        Boot the virtual machine.
        You will be prompted to enter the passphrase for the encrypted partitions during boot.

    Verify Functionality:
        Once Debian boots, check if all partitions are accessible and the system functions as expected.

Important Notes

    Permissions: Running VirtualBox with the necessary permissions to access the physical disk is crucial.
    EFI Settings: If Debian is installed with UEFI, ensure that EFI is enabled in the VM settings.
    Disk Encryption: Be ready to provide the decryption passphrase for your encrypted drive when booting the VM.
    Data Safety: Regularly back up important data on your external NVMe drive to avoid data loss.
