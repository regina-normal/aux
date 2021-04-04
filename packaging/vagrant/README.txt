Windows 10 VirtualBox / Vagrant setup
=====================================

-------------------------------------
1. Set up the VirtualBox VMs
-------------------------------------

Initial installation:
- user account: virtualbox

Perform all windows updates
- activation fails (cannot reach server) but don't worry about that

Enable Administrator account:
- search for "cmd", select "run as administrator"
  > net user administrator (see that active is no)
  > net user administrator /active:yes
  > net user administrator (see that active is yes)
- set password via control panel

Set up WinRM:
- Set network type to private via settings
- search for "cmd", select "run as administrator"
  > winrm quickconfig
  > sc config WinRM start= auto
  > winrm set winrm/config/winrs @{MaxMemoryPerShellMB="512"}
  > winrm set winrm/config @{MaxTimeoutms="1800000"}
  > winrm set winrm/config/service @{AllowUnencrypted="true"}
  > winrm set winrm/config/service/auth @{Basic="true"}

Turn off UAC (User Account Control, which prompts when using admin rights):
- Control Panel -> User accounts -> User Accounts -> Change UAC Settings,
  change to "never notify"

Install VirtualBox guest additions

Set up OpenSSH server:
- Install via Settings -> Apps & Features -> Optional Features
- As administrator:
  > sc config sshd start= auto
  > netsh advfirewall firewall add rule \
    name="OpenSSH Server" dir=in action=allow protocol=TCP localport=22

Clean up hard drive:
- In Settings -> System -> Storage:
  + Remove all temporary files, inc. previous Windows installation(s)
  + Optimise C: drive

Install MSYS2:
- Run installer
- Update everything via "pacman -Syuu"
- Install utilities and build-dependencies required by Regina
- Clean via "pacman -Scc"

Install Qt (via online installer) and WiX

Add the candle/light aliases and PKG_CONFIG_PATH to ~/.bashrc

Create SSH keys on the host:
- Generate a public/private keypair on the host in /usr/local/virtualbox
- Name the public key vbox-key.pub, with world read permissions
- Name the private key vbox-key, with user/group-only permissions, using
  the vboxusers group
- Copy vbox-key to vbox-key-$USER for each virtualbox user, with the
  owner set to $USER, and with user-only permissions, as required by ssh

Install SSH keys onto the guest:
- Put the public key in \ProgramData\ssh\administrators_authorized_keys
- Fix the access control list for this file, as required by ssh:
    icacls.exe .\administrators_authorized_keys /inheritance:r
    icacls.exe .\administrators_authorized_keys /grant SYSTEM:`(F`)
    icacls.exe .\administrators_authorized_keys /grant BUILTIN\Administrators:`(F`)

Take a VirtualBox snapshot, named "regina"

-------------------------------------
2. Set up the Vagrant boxes
-------------------------------------

Install vagrant plugins:
- Vagrant needs the winrm, winrm-fs and winrm-elevated plugins to use the WinRM
  communicator.  For this we install locally built ruby-winrm{,-fs,-elevated}
  packages, which is enough for vagrant to locate and use.
- These local packages in turn require a locally built ruby-ntlm package,
  since the version in bullseye is too old.
- See gem2deb for a quick way to create ad-hoc ruby packages.
- BUT: our vagrant boxes use ssh instead of winrm, so installing these plugins
  is completely optional.

Create and install the vagrant base boxes:
- From this directory, run: ./mkboxes

For ad-hoc use of the vagrant VMs:
- In a different directory, set up the VM:
  $ vagrant init regina/win10
  $ vagrant up
- To start a bash shell from the host:
  $ vagrant ssh -c 'c:\msys64\usr\bin\env MSYSTEM=MINGW64 /usr/bin/bash -li'
- To start a bash shell from a normal cmd/powershell prompt within the guest,
  see bash.cmd in this directory.

-------------------------------------
Things we do *not* need to do
-------------------------------------

In setting up the VirtualBox machines, vagrant recommends some additional
steps that appear to be unnecessary here.  These include:
- Turn off UAC via the registry also, by running as administrator:
  > reg add HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /d 0 /t REG_DWORD
  The "reg add" command takes an extra /reg:64 or /reg:32 switch on a
  64-bit machine to access the 64-bit vs 32-bit registries.
- Disable complex passwords
- Disable shutdown tracker (specific to Windows Server?)
- Disable "server manager" starting at login (specific to Windows Server?)

If we ever want to generate the public key from vagrant's own insecure SSH key:
$ ssh-keygen -y -f ~/.vagrant.d/insecure_private_key

