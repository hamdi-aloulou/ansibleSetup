# ansibleSetup

1. sudo apt-get install ansible
2. sudo pip install paramiko --upgrade
3. ansible-playbook -vvv setup.yml -i hosts --ask-pass --sudo -c paramiko

# Changing UbiServer (system already installed)

1. ssh into the RaspberryPi
2. sudo vim /lib/systemd/system/ubigate.service
3. sudo systemctl daemon-reload
4. sudo systemctl restart ubigate

## Enable registration requests
When changing server configuration, mind remove current credentials:

```
# Tell the gateway that it is no more associated to configured house.
# Optional. This file will be replaced during a new registration anyway
sudo rm /root/.config/ubigate/config.json

# Remove current association so that it can be discovered in gateway registration
sudo rm /root/.config/ubigate/credentials.json

# Let the modification take effect
sudo systemctl restart ubigate
```

With SensorML, existing xml files seem to prevent the reception of configuration file (config.json)

```
# Remove XML files
rm ~/*.xml

# Let the modification take effect
sudo systemctl restart ubigate
```
To get the `config.json`, in web-interface of UbiSmart, go to _homedesc_ of the house and click on Submit.

## Enabling SSH in Rasbian (Jessie PIXEL (25/11/2016) ++)

Since 25/11/2016, SSH is disabled by default on Raspberry. In order to activate ssh, two options are available.
 - through raspi-config or the application Raspberry Pi Configuration (this requires a screen and a keyboard)
 - by addding a file named SSH to the boot particiption of the SD card (just plug the SD card to your computer and you will be able to access the boot particition). The SSH file can be empty or contain any text. When the Raspberry Pi starts, it looks for that file. If it finds it, it activates SSH and then deletes the file.
 
