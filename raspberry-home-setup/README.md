# Raspberry Pi home setup

## Basic setup

1. Download Raspbian Buster Lite Minimal image here: https://www.raspberrypi.org/downloads/raspbian/
2. Use something like https://www.balena.io/etcher/ to write the image on a SD card (8Gb in my case)
3. Put the card in the raspberry pi, plug it to a screen, keyboard and mouse and boot, login with login: `pi`, password: `raspberry`
4. Type `raspi-config` > localisation > keyboard layout to get azerty
5. Type `passwd` to change your user current password
6. run `sudo apt-get update && sudo apt-get upgrade` (it will take ~5min, don't forget to press "enter" at some point, that's very unclear)
7. Configure the wifi connection at boot in `sudo nano /etc/wpa_supplicant/wpa_supplicant.conf`
    Scroll to the end of the file and add the following to the file to configure your network:
    ```
    network={
        ssid="Test Wifi Network"
        psk="SecretPassWord"
    }
    ```
    check if working using: `ifconfig wlan0` (or ping a website) (if not working, try `sudo reboot`)
8. Enable ssh in `raspi-config` > interfaces, you can now connect to it with `ssh pi@192.168.0.17` (find out the ip with `ifconfig`)
9. Set a static IP to your raspberry on wired or wireless networks:
    Make sure dhcpcd service is running with `sudo service dhcpcd status` (if not enable it with `sudo service dhcpcd start` & `sudo systemctl enable dhcpcd`)
    Change the configuration with `sudo nano /etc/dhcpcd.conf`, and add this at the end of the file (No spaces between lines!):

    ```
    interface eth0
    static ip_address=192.168.0.17/24
    static routers=192.168.0.1
    static domain_name_servers=192.168.0.1
    ```

    Or if you are using wifi instead of ethernet on the pi:
    ```
    interface wlan0
    static ip_address=192.168.0.17/24
    static routers=192.168.0.1
    static domain_name_servers=192.168.0.1 # (or google magic "8.8.8.8" if for some reason your router is poorly configured)
    ```

    Reboot with `sudo reboot`

## Install external Disk

1. Check if the disk is here with `sudo lsblk -o UUID,NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL,MODEL` (and take note of it's UUID)
2. If it's type is NTFS install `sudo apt install ntfs-3g`
3. Find your disk UUID string: `sudo blkid` in my case "/dev/sda1"
4. Create a location for the mount point `sudo mkdir /media/external` and assign permissions `sudo chmod 777 /media/external`
5. Mount the drive with `sudo mount -t ntfs-3g /dev/sda1 /media/external` (check that it as worked `ls /media/external`)
6. Let's do the same thing after each reboot, make a copy of the config fstab file `sudo cp /etc/fstab /etc/fstab.backup`
7. Edit it: `sudo nano /etc/fstab` add a new line `UUID=THE_UUID_OF_YOUR_DISK /media/external ntfs-3g nofail 0 0`

## Install deluged

Mainly from : https://www.howtogeek.com/142044/how-to-turn-a-raspberry-pi-into-an-always-on-bittorrent-box/

1. `sudo apt-get install deluged` then `sudo apt-get install deluge-console`
2. `deluged` then `sudo pkill deluged` This starts the Deluge daemon (which creates a configuration file) and then shuts down the daemon. We’re going to edit that configuration file and then start it back up.
3. `cp ~/.config/deluge/auth ~/.config/deluge/auth.old` `nano ~/.config/deluge/auth` Type in the following commands to first make a backup of the original configuration file and then open it for editing:
4. At the end of the file add: `user:password:level` Where user is the username you want for Deluge, password is the password you want, and thelevel is 10 (the full-access/administrative level for the daemon). So for our purposes, we used pi:raspberry:10.
5. start up the daemon and console again: `deluged` then `deluge-console`
6. `config -s allow_remote True`, `config allow_remote` then `exit` (This enables remote connections to your Deluge daemon and double checks that the config variable has been set.)
7. restart the deamon: `sudo pkill deluged` then `deluged`
8. On your main computer, start deluge client, go to configuration > interface and untick "classic mode", restart it.
9. You'll be asked to connect to reamote deamon, enter your pi ip, leave the default port and enter your deluge username and password.
10. Go to configuration, change the place where torrent are downloaded, configure your VPN if needs be.
11. Make it run at startup, open: `sudo nano /etc/rc.local` and add this line at the end of the file
    ```
    # Start Deluge on boot:
    sudo -u pi /usr/bin/python /usr/bin/deluged
    ```

If you wish to intall the web UI follow the part 2 of: https://www.howtogeek.com/142044/how-to-turn-a-raspberry-pi-into-an-always-on-bittorrent-box/

## Install Plex

1. Go to https://www.plex.tv/, downloads choose Linux > "Ubuntu / Debian ARMv7" copy the link to the file.
2. In the pi dl the .deb file `wget -O plexmediserver.deb https://downloads.plex.tv/plex-media-server-new/1.16.5.1488-deeb86e7f/debian/plexmediaserver_1.16.5.1488-deeb86e7f_arm hf.deb`
3. Install it with `sudo dpkg -i plexmediserver.deb` then `sudo apt-get install -f`
4. Open `sudo nano /etc/default/plexmediaserver` replace "plex" with "pi" in the `export PLEX_MEDIA_SERVER_USER=plex` line (fore easier handling of permission, I know that's not ideal)
5. Restart the service `sudo service plexmediaserver restart`
6. Go to http://192.168.0.17:32400/web and configure your acount and your folders on your disks



## Making the Disk Available Using SMB

1. `sudo apt-get install samba samba-common-bin` (if asked "Modify smb.conf to use WINS settings from DHCP?" choose No)
2. Edit `sudo nano /etc/samba/smb.conf` and add
    ```
    [share]
    Comment = Pi shared folder
    Path = /media/external
    Browseable = yes
    Writeable = Yes
    only guest = no
    create mask = 0777
    directory mask = 0777
    Public = yes
    Guest ok = yes
    ```

    Omit the `Guest ok = yes` if you don't want to allow guests (but that didn't work for me, I have to look into it)
    3. `sudo smbpasswd -a pi`
3. Restart the samba deamon `sudo service smbd restart`

## Setting up SSH Keys
1. `cd ~` and `mkdir .ssh` if not there. `cd .ssh` & `touch authorized_keys`
2. Set permissions `chmod 700 ~/.ssh` and `chmod 600 ~/.ssh/authorized_keys`
3. Create the key pair on your client with `ssh-keygen` if you don't have one (no password, default name)
4. And add the `id_rsa.pub` of the client to `authorized_keys`
5. Try to ssh you'll not be asked any password
