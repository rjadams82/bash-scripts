#!/bin/bash

# XRDP Installation & Configuration Script for Linux (Debian/Ubuntu)
# Allows choosing a custom RDP port (default: 3390)
# Allows choosing the UI

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== XRDP Setup Script ===${NC}"

# Prompt for RDP port with a default of 3390
read -p "Enter desired RDP port [default: 3390]: " RDP_PORT
RDP_PORT=\${RDP_PORT:-3390}
echo -e "Using RDP Port: ${YELLOW}\$RDP_PORT${NC}"

# Prompt for desktop environment choice
echo "Choose a desktop environment to install:"
echo "1) XFCE (Recommended)"
echo "2) LXDE"
read -p "Enter choice [1 or 2, default: 1]: " DE_CHOICE
DE_CHOICE=\${DE_CHOICE:-1}

# 1. Update system
echo -e "${GREEN}[1/7] Updating package lists and upgrading system...${NC}"
sudo apt update && sudo apt -y upgrade

# 2. Install Desktop Environment
if [ "\$DE_CHOICE" -eq 2 ]; then
    echo -e "${GREEN}[2/7] Installing LXDE...${NC}"
    sudo apt install -y lxde
    SESSION_CMD="startlxde"
else
    echo -e "${GREEN}[2/7] Installing XFCE (and goodies)...${NC}"
    echo "** If prompted for display manager during lightdm install, select lightdm **"
    sudo apt install -y xfce4 xfce4-goodies lightdm
    SESSION_CMD="startxfce4"
fi

# Note: If prompted for display manager during lightdm install, select lightdm.

# 3. Install XRDP and configure port & color depth
echo -e "${GREEN}[3/7] Installing XRDP...${NC}"
sudo apt-get install -y xrdp

echo -e "${GREEN}Configuring xrdp.ini (Port and BPP)...${NC}"
sudo cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak

# Change default port from 3389 to chosen port
sudo sed -i "s/3389/\$RDP_PORT/g" /etc/xrdp/xrdp.ini

# Adjust BPP settings
sudo sed -i 's/max_bpp=32/#max_bpp=32\nmax_bpp=128/g' /etc/xrdp/xrdp.ini
sudo sed -i 's/xserverbpp=24/#xserverbpp=24\nxserverbpp=128/g' /etc/xrdp/xrdp.ini

# 4. Configure startwm.sh
echo -e "${GREEN}[4/7] Configuring startwm.sh...${NC}"
sudo cp /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.bak

# Comment out default session lines
sudo sed -i '/test -x \/etc\/X11\/Xsession && exec \/etc\/X11\/Xsession/s/^/# /' /etc/xrdp/startwm.sh
sudo sed -i '/exec \/bin\/sh \/etc\/X11\/Xsession/s/^/# /' /etc/xrdp/startwm.sh

# Append desktop session command to the end of the file
echo -e "\n# start desktop session manager\n\$SESSION_CMD" | sudo tee -a /etc/xrdp/startwm.sh > /dev/null

# 5. Enable & start D-Bus
echo -e "${GREEN}[5/7] Enabling and starting D-Bus...${NC}"
sudo systemctl enable dbus
sudo /etc/init.d/dbus start

# 6. Set XRDP / target runlevel
echo -e "${GREEN}[6/7] Setting target runlevel link...${NC}"
sudo ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target

# 7. Start XRDP service
echo -e "${GREEN}[7/7] Starting XRDP service...${NC}"
sudo /etc/init.d/xrdp start

echo -e "${GREEN}=== Installation Complete! ===${NC}"
echo -e "XRDP is now running on port ${YELLOW}\$RDP_PORT${NC} with session: ${YELLOW}\$SESSION_CMD${NC}"
sudo /etc/init.d/xrdp status
