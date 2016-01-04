# ansibleSetup

1. sudo apt-get install ansible
2. sudo pip install paramiko --upgrade
3. ansible-playbook -c paramiko -i hosts setup.yml --ask-pass --sudo
4. ansible-playbook -i hosts site.yml
