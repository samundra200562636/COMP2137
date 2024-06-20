#!/bin/bash

# This script provides a system report that includes a variety of system information.

# It contains system information like hostname, operating system, and uptime, as well as hardware information like CPU, RAM, speed disks and video.

# It consist of network information, including FQDN, Host address, Gateway IP, DNS server including InterfaceName and IP Address 
#In system status, it includes logged-in users, Disk Space, Process Count, Load Averages, Memory allocation, Listening Network Ports and UFW Rules.

#Script to generate a system information report

HOSTNAME=$(hostname)                            # This will get us the hostname of the system
DISTRO=$(source /etc/os-release && echo $PRETTY_NAME)  # This will get us the distribution name and version
UPTIME=$(uptime -p)                             # This will get the uptime of the system


#Script to get the hardware information

CPU=$(lshw -c cpu | awk '/product/ {print $2" "$3}') # This will get CPU make and model
CPU_SPEED=$(lscpu | awk '/^CPU MHz/ {print $3}' | sort -rn | head -n1)  # This will get the current CPU speed
MAX_SPEED=$(lscpu | awk '/^CPU max MHz/ {print $4}')  # This will get maximum CPU speed
RAM=$(free -h | awk '/Mem/ {print $2}')           # This will get installed RAM size
DISKS=$(lsblk -o NAME,MODEL,SIZE | awk '{if (NR>1) print $2" "$3" "$4}')  # This will get disk information
VIDEO=$(lshw -c video | awk '/product/ {print $2" "$3}')  # This will get video card make and model

#Script to get the network Information
FQDN=$(hostname -f)                            # This will get the fully qualified domain name
IP_Host=$(hostname -I | awk '{print $1}')      # This will get the host IP address
GATEWAY_IP=$(ip r | awk '/default/ {print $3}')   # This will get the gateway IP address
DNS_SERVER=$(grep nameserver /etc/resolv.conf | awk '{print $2}')  # Get the DNS server IP address
INTERFACE=$(lshw -c network | awk '/logical name/ {print $3}' | head -n1)  # This will get network interface name
IP_ADDRESS=$(ip a show $INTERFACE | awk '/inet/ {print $2}')  # This will get the  IP address of the network interface

#Script to get the System Status
USERS=$(who | awk '{print $1}' | sort -u | tr '\n' ',')  # This will get currently logged in users
USERS=${USERS%,}                              # It will remove trailing comma
DISK_SPACE=$(df -h | awk '/^\/dev/ {print $1" "$4}')    # This will get free disk space
PROCESS_COUNT=$(ps -ef | wc -l)                    # This will get process count
LOAD_AVERAGES=$(uptime | awk -F'[a-z]:' '{print $2}')    # This will get load averages
MEMORY_ALLOCATION=$(free -h | awk '/Mem/ {print "Total: "$2", Used: "$3", Free: "$4}')  # This will get memory allocation
LISTENING_PORTS=$(ss -lntu | awk 'NR>1 {print $5}' | cut -d: -f2 | sort -u | tr '\n' ',') # This will get listening network ports
LISTENING_PORTS=${LISTENING_PORTS%,}                   # It will remove trailing comma
UFW_RULES=$(sudo ufw status numbered | awk '{print $2" "$3" "$4" "$5" "$6}')  # This will get UFW rules

# This is the Output, that we will get through the whole script
cat <<EOF

System Report generated by $USER, $(date)

System Information
-------------------

Hostname: $HOSTNAME                         # It will display the hostname
OS: $DISTRO                               # It will display the OS information
Uptime: $UPTIME                            # It will display system uptime

Hardware Information 
---------------------

CPU: $CPU                                 # It will display the CPU information
Speed: $CPU_SPEED MHz (Max: $MAX_SPEED MHz)   # It will display the CPU speed
RAM: $RAM                                 # It will display the RAM information
Disk(s): $DISKS                            # It will display the disk information
Video: $VIDEO                              # It will display video card information

Network Information 
---------------------
FQDN: $FQDN                               # It will display the appropriate domain name
Host Address: $IP_Host                       # It will display the host IP address
Gateway IP: $GATEWAY_IP                      # It will display the gateway IP address
DNS Server: $DNS_SERVER                      # It will display the DNS server IP address

Interface: $INTERFACE                        # It will display the network interface
IP Address: $IP_ADDRESS                      # It will display the IP address of the network interface

System Status 
------------------
Users Logged In: $USERS                     # It will display the logged-in users
Disk Space: $DISK_SPACE                     # It will display the disk space information
Process Count: $PROCESS_COUNT                # It will display the process count
Load Averages: $LOAD_AVERAGES                # It will display the load averages
Memory Allocation: $MEMORY_ALLOCATION          # It will display the memory allocation
Listening Network Ports: $LISTENING_PORTS      # It will display the listening network ports
UFW Rules: $UFW_RULES                       # It will display the UFW rules

EOF
