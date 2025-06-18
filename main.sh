#!/usr/bin/bash

# Define the installation directory explicitly
INSTALL_DIR=$(pwd)

#If Postgresql services already installed removing
if systemctl is-active --quiet "postgresql-14"; then
  echo "Postgresql services already installed removing"
  systemctl stop postgresql-14
  systemctl disable postgresql-14
  dnf remove -y postgresql14 postgresql14-server postgresql14-libs postgresql14-contrib postgresql14-devel
  rm -rf /var/lib/pgsql/14/
  userdel -r postgres
  rm -rf /etc/postgresql*
  rm -rf /var/log/postgresql/
fi
#If Redis services already installed removing
if systemctl is-active --quiet "redis"; then
  echo "Redis services already installed removing"
  systemctl stop redis
  systemctl disable redis
  dnf remove -y redis
  rm -rf /etc/redis/
  rm -rf /var/lib/redis/
  rm -rf /var/log/redis/
  userdel -r redis
fi

#If Redis services already installed removing
if systemctl is-active --quiet "grok-exporter"; then
  echo "grok-exporter services already installed removing"
  systemctl stop grok-exporter
  systemctl disable grok-exporter
fi

if systemctl is-active --quiet "threatidr"; then
  echo "grok-exporter services already installed removing"
  systemctl stop grok-exporter
  systemctl disable grok-exporter
  rm -rf /opt/grok-exporter
fi
#Clening the product folder
rm -rf /opt/grok-exporter
rm -rf /usr/share/nginx/html/threatidr
# Countdown animation
countdown() {
  local seconds="$1"
  echo -e "\nPausing for $seconds seconds..."
  while [ "$seconds" -gt 0 ]; do
    printf "\rRebooting in %2d seconds... " "$seconds"
    sleep 1
    ((seconds--))
  done
  echo -e "\n"
}

final_message(){

# Add a decorative border
echo -e "\033[1;34m========================================\033[0m"

# Display installation complete message
echo -e "\033[1;32mInstallation complete.\033[0m"
echo -e "\033[1;34mRun the \033[1;33m'TIDR Status'\033[1;34m command to check the service status after reboot.\033[0m"

# Add a blank line for spacing
echo

# Display credentials message
echo -e "\033[1;32mCredentials have been created.\033[0m"
echo -e "\033[1;34mYou can find them in \033[1;33m'/root/credentials.txt'\033[1;34m for login instructions.\033[0m"

# Add a decorative border
echo -e "\033[1;34m========================================\033[0m"
}



# Load configurations
source "${INSTALL_DIR}/config.env"
source "${INSTALL_DIR}/scripts/generate_random_credentials.sh"

# Check environment requirements
source "${INSTALL_DIR}/scripts/check_environment.sh"

# Install required packages and dependencies
source "${INSTALL_DIR}/scripts/install_dependencies.sh"

# Install and configure services
source "${INSTALL_DIR}/scripts/install_services.sh"

# Setup configurations for services
source "${INSTALL_DIR}/scripts/setup_services.sh"

# Configure Nginx
source "${INSTALL_DIR}/scripts/configure_nginx.sh"

# Set up Grok exporter
source "${INSTALL_DIR}/scripts/configure_grok_exporter.sh"

# Set up ThreatIDR
source "${INSTALL_DIR}/scripts/configure_threatidr.sh"

# Disable SE Linux
source "${INSTALL_DIR}/scripts/configure_se_linux.sh"

# Configure BIND DNS
source "${INSTALL_DIR}/scripts/configure_bind.sh"

# Ask for License Key.
source "${INSTALL_DIR}/scripts/license.sh"

# Reload systems
source "${INSTALL_DIR}/scripts/restart_systems.sh"


# Uninstall services
# source "${INSTALL_DIR}/scripts/uninstall_services.sh"


store_passwords() {
  output="Please store these passwords for future use
----------------------------------------
REDIS_PASSWORD=${REDIS_PASSWORD}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
ADMIN_PASSWORD=${ADMIN_PASSWORD}
----------------------------------------"

  # Display the passwords
  echo "$output"

  Save the passwords to /root/credentials.txt
  echo "$output" > /root/credentials.txt
}

store_passwords


log_message "Finishing Installation in 10 seconds..."
countdown 10

final_message


# Countdown before reboot
log_message "Waiting for 15 seconds before rebooting..."
countdown 15

# Reboot the machine
log_message "Rebooting the machine now..."
if sudo reboot; then
  log_message "Reboot command executed successfully."
else
  log_message "Failed to execute reboot command. Please reboot manually."
  exit 1
fi



