#!/bin/bash





# Install opentofu

1. installation de opentofu d'après le script officiel
```
# Download the installer script:
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
# Alternatively: wget --secure-protocol=TLSv1_2 --https-only https://get.opentofu.org/install-opentofu.sh -O install-opentofu.sh

# Give it execution permissions:
chmod +x install-opentofu.sh

# Please inspect the downloaded script

# Run the installer:
./install-opentofu.sh --install-method deb

# Remove the installer:
rm -f install-opentofu.sh
```

# Install ansible
1. installation de ansible depuis le dépot de paquet
```bash
sudo apt-get install -y ansible
```
2. Tester le fonctionnement de ansible
```
ansible -m ping localhost
```
