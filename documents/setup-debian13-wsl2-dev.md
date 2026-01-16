## Debian 13 WSL2 Setup for BareMetal-C-Dev
Click start and type:
```
turn windows features on or off
```
scroll down and check `Windows Subsystem for Linux`.

Reboot if necessary.
### Check your current WSL version:
Type `Win+R` and run `cmd` or `powershell`:
```
wsl --version
```
If it says `WSL version: 2.x`, you're ok,
> but if it is `1.x`, you must update `WSL` to `WSL2` by:
> ```
> wsl --update
> ```
> Reboot if necessary.

Now do the safety check.
```
wsl --list
```
If it contains `Debian`, proceed at your own risk!
### Install Debian
```
wsl --install Debian
```
This will take a while. You'll be asked for a new username. Use
```
verif
```
and just add a simple password (type it twice). We won't be doing anything unsecure on this machine.
### update `sudo` so we can do it without password
Your prompt should now read: `dev@something:/mnt/c/Users/name$`, type:
```bash
sudo visudo
```
give the password. scroll down this file until you see: `%sudo   ALL=(ALL:ALL) ALL`. Add a new line below it and type:
```
verif ALL=(ALL) NOPASSWD: ALL
```
so now that part reads:
> ```
> # Allow...
> %sudo   ALL=(ALL:ALL) ALL
> verif ALL=(ALL) NOPASSWD: ALL
> 
> # See...
> ```
Type: `ctrl-o`, type `enter`, then `ctrl-x`, you will be back at `dev@something:/mnt/c/Users/name$`

## Install `oss-cad-suite`

change directory to home:
```
cd ~/
```

install necessary software:
```
sudo apt update && sudo apt upgrade -y
```

install software:
```
sudo apt install -y make gcc git
```

clone this repo:
```
git clone https://github.com/kongkrit/RTL-Verification-Workshop
```

cd into `sim`
```
cd sim
```

Install python on linux
```
./1_install_python_linux.sh
```

Install `oss-cad-suite`
```
python3 2_setup_oss_cad.py
```


---

---

---

### Prettify:
- Print out distro name and alias `l` `ll` `la`
- Change `ls` colors
- Change prompt
```bash
cat <<'EOF' >> ~/.bashrc

alias ls='ls --color=auto'
alias l='ls -CF --color=auto'
alias la='ls -A --color=auto'
alias ll='ls -l --color=auto'
alias vim='vi'

export LS_COLORS='di=00;36:ow=01;36:st=01;36:ex=01;32:ln=01;36'

export PS1='\[\033[01;33m\][\u]\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\] \$ '
# --- Distro display ---
if [ -f /etc/os-release ]; then
    . /etc/os-release
    PS1="(${ID^})$PS1"
fi

EOF
```
  ```
You will be back at `(Debian)[baremetal-dev]:/mnt/c/Users/name $` prompt.
