#!/bin/bash

## Firstly, we are performing the Network Configuration
if [ -f "$netplan_file" ]; then
    # Here, we are checking and updating the persistent network configuration for the 192.168.16.21/24 interface
    if ! grep -q "address: 192.168.16.21/24" "$netplan_file"; then
        echo "Updating network configuration..."
        sed -i 's/address: .*/address: 192.168.16.21\/24/' "$netplan_file"
        netplan apply
    else
        echo "Network configuration is already correct."
    fi
else
    echo "Netplan configuration file $netplan_file not found. Skipping network configuration update."
fi

# Then, we are configuring the /etc/hosts file
# Here, we are verifying the /etc/hosts file has the correct entry for server1
if ! grep -q "192.168.16.21 server1" /etc/hosts; then
    echo "Updating /etc/hosts file..."
    echo "192.168.16.21 server1" >> /etc/hosts
else
    echo "/etc/hosts file is already been correct."
fi

# Secondly, we are doing the software installation process.
#Here, we are installing the  Apache2 and Squid
if ! dpkg-query -W -f='${Status}' apache2 | grep -q "install ok installed"; then
  echo "Installing the Apache2"
  apt-get update
  apt-get install -y apache2
else
  echo "Apache2 is already been installed."
fi

if ! dpkg-query -W -f='${Status}' squid | grep -q "install ok installed"; then
echo "Installing Squid..."
  apt-get install -y squid
else
  echo "Squid is already been installed."
fi

# Thirdly, we are configuring the firewall.
# Here, we are enabling and configuring the firewall
if ! ufw status | grep -q "active"; then
  echo "Enabling UFW firewall..."
  ufw default deny
  ufw allow 22 from 192.168.16.0/24
  ufw allow 80
  ufw allow 3128
  ufw --force enable
else
  echo "UFW firewall is already been enabled and configured successfully."
fi

#Fourthly, we are managing and creating the user accounts with specified configuration.
# Here, we are creating the different users with specified configurations
echo "Creating user accounts"

# Here, we are creating the 'dennis' user with sudo access and the provided SSH key
if ! id -u dennis &> /dev/null; then
  useradd -m -s /bin/bash dennis
  echo "dennis ALL=(ALL:ALL) ALL" >> /etc/sudoers
  mkdir -p /home/dennis/.ssh
  echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" >> /home/dennis/.ssh/authorized_keys
else
  echo "User 'dennis' already been exists."
fi

# Lastly, we are creating the SSH keys
for user in aubrey captain snibbles brownie scooter sandy perrier cindy tiger yoda; do
 if ! id -u $user &> /dev/null; then
    useradd -m -s /bin/bash $user
    mkdir -p /home/$user/.ssh
    ssh-keygen -t rsa -N "" -f /home/$user/.ssh/id_rsa
    ssh-keygen -t ed25519 -N "" -f /home/$user/.ssh/id_ed25519
    cat /home/$user/.ssh/id_rsa.pub >> /home/$user/.ssh/authorized_keys
    cat /home/$user/.ssh/id_ed25519.pub >> /home/$user/.ssh/authorized_keys
  else
    echo "User '$user' is already been existed."
  fi
done

echo "Script been executed successfully".
