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
