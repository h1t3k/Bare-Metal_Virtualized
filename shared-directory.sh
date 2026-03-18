On the host in VirtualBox Manager

With the VM powered off or running, go to:

Settings → Shared Folders → add folder icon

Set:
	•	Folder Path: the host folder you want to share
	•	Folder Name: something clean, like shared
	•	Auto-mount: optional
	•	Make Permanent: optional if you want it to stay
	•	Read-only: leave unchecked unless you want that

VirtualBox supports permanent or transient shares, and Linux guests use the vboxsf filesystem for them.  

In Debian guest

First, make sure your user is in the vboxsf group, because on Linux guests shared folders are accessible to root and members of vboxsf.  

Run:

sudo usermod -aG vboxsf "$USER"

Then either log out and back in, or just reboot the VM.

Manual mount method

This is the most reliable way when you want it exactly where you want it.

Create a mount point:

sudo mkdir -p /mnt/shared

Mount it:

sudo mount -t vboxsf shared /mnt/shared

Replace shared with whatever Folder Name you gave it in VirtualBox Manager.

Check that it mounted

mount | grep vboxsf
ls -la /mnt/shared

If you enabled auto-mount

VirtualBox often mounts Linux shared folders under something like:

/media/sf_shared

Access on Linux guests is still gated by vboxsf group membership.  

If you want it mounted every boot

Add this to /etc/fstab:

shared   /mnt/shared   vboxsf   defaults,uid=1000,gid=1000   0   0

sudo systemctl daemon-reload

Then test it:

sudo mount -a

If your user is not UID/GID 1000, check with:

id

and swap the values in fstab.

Fastest path

If you want the “I just need this working right now” version:

sudo usermod -aG vboxsf "$USER"
sudo mkdir -p /mnt/shared
sudo mount -t vboxsf shared /mnt/shared

Then reopen session/reboot if permissions act weird.

If mount: unknown filesystem type 'vboxsf' pops up, Guest Additions did not finish loading cleanly even if it looked installed.
