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
        To set the proper permissions for the VMDK file in macOS, you will typically need to ensure that your user account has read and write access to both the VMDK file and the raw disk it references. Here's how to do it:

    Change Ownership of the VMDK File:
        First, change the ownership of the VMDK file to your current user. Use the chown command in Terminal:

        bash

    sudo chown $(whoami) /path/to/your.vmdk

    Replace /path/to/your.vmdk with the actual path to your VMDK file.

Change Permissions of the VMDK File:

    Next, modify the file permissions to ensure your user has read and write access. Use the chmod command:

    bash

        chmod 644 /path/to/your.vmdk

    Grant Current User Access to the Raw Disk:
        The current user must have access to the raw disk as well. This can be tricky, as direct access to physical disks typically requires root privileges. However, you can use the sudo command to run VirtualBox with root privileges when accessing the disk.
        Alternatively, if you want to grant your user direct access to the disk (which can have security implications), you could change the ownership of the disk device file, but this is generally not recommended. Instead, running VirtualBox with elevated privileges when accessing this VM is safer.

    Verify Permissions:
        Verify the permissions using ls -l /path/to/your.vmdk. Ensure the output shows your username with read and write permissions.

Running VirtualBox with Elevated Privileges

Since accessing raw disks typically requires root privileges, you might need to start VirtualBox with elevated privileges when using this VM. To do this, you can use:

        sudo /Applications/VirtualBox.app/Contents/MacOS/VirtualBox

Important Note

    Security Concerns: Be cautious when changing permissions and ownerships of system files or when running applications with elevated privileges. It's crucial to understand the security implications, as it can pose risks to your system's security and stability.
    Regular User Access: It's usually not recommended to give regular users direct access to raw disk devices because of the potential security risks and the possibility of accidental data loss.

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



Advanced Parameters:

Changing Ownership of the Raw Disk

    Identify the Disk Device:
        Ensure you know the exact identifier of your external NVMe drive (e.g., /dev/disk2). You can use diskutil list to list all connected drives and find your NVMe drive.

    Unloading Disk Arbitration Framework:
        Disk access in macOS is managed by the Disk Arbitration framework, which needs to be unloaded to change ownership. Unload it using:

        bash

    sudo launchctl unload /System/Library/LaunchDaemons/com.apple.diskarbitrationd.plist

    Be cautious: Unloading this can affect system stability and access to other disk devices.

Change Ownership of the Disk Device:

    Change the ownership of the disk device file to your user. Replace /dev/diskX with your device identifier:

    bash

    sudo chown $(whoami) /dev/diskX

    This command assigns ownership of the disk device file to your current user account.

Reload Disk Arbitration Framework:

    Once you've changed the ownership, reload the Disk Arbitration framework:

    bash

        sudo launchctl load /System/Library/LaunchDaemons/com.apple.diskarbitrationd.plist

Important Considerations

    Temporary Change: These changes are temporary and will reset after a reboot. If you need to access the disk regularly, you'll need to repeat these steps or consider automating them (which is generally not recommended).
    Risk of Data Loss: Direct access to raw disks can lead to unintentional data loss if not handled carefully. Ensure you have backups of your data.
    System Security and Stability: Modifying ownership of disk devices and unloading critical system services can pose risks to the security and stability of your system. Perform these actions only if you are confident in your understanding of their implications.
    Usage of Sudo: Commands that begin with sudo are executed with administrative privileges and should be used with caution.

Remember, this is an advanced operation and typically not recommended for casual use. Ensure you fully understand the implications and risks before proceeding.
