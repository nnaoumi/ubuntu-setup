#!/bin/bash

#Script to automatically install selected packages and configure a fresh Ubuntu install.

#Script has been tested on Ubuntu 19.04
#Be sure to change the permission of the script to 774 in order to be able to execute it.
#Use the following command: sudo chmod 774 script_name.sh

#List of functions
addRepositories() {
    
    #Google Repository
    echo ""
    echo ""
    echo "Downloading setup key and setting up repository for Google..."
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

    #Microsoft Repository
    echo ""
    echo ""
    echo "Installing Curl..."
    sudo apt-get -y install curl
    
    echo ""
    echo ""
    echo "Downloading setup key and setting up repository for Microsoft..."
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

    rm microsoft.gpg

}

enableHibernationAfterSleep() {

    #If you have any issues, delete logind.conf and sleep.conf.
    #Ubuntu will restore a default logind.conf file when deleted.
    #sleep.conf does not exist in ubuntu by default. It can safely be deleted.
    
    echo ""
    echo ""
    echo "Enabling automatic hibernation after 90 minutes of sleep..."

    #Creating sleep.conf file and moving it to /etc/systemd
    echo "[Sleep]" >> sleep.conf
    echo "HibernateDelaySec=7200" >> sleep.conf
    echo "" >> sleep.conf
    echo "#This file hibernates the pc after it is suspended for a predetermined amount of time." >> sleep.conf
    echo "#Copy the file to /etc/systemd/" >> sleep.conf
    echo "#Test hibernation delay with: sudo systemctl suspend-then-hibernate" >> sleep.conf

    sudo mv sleep.conf /etc/systemd/
    sudo chmod 644 /etc/systemd/sleep.conf

    #Adding a line to logind.conf
    echo "HandleLidSwitch=suspend-then-hibernate" >> /etc/systemd/logind.conf
    sudo chmod 644 /etc/systemd/logind.conf

}

installPackages() {
    
    #tlp saves battery power on laptops. code package is microsoft's vs code.
    appList=(keepass2 transmission vlc grub-customizer tlp google-chrome-stable code gnome-tweaks ttf-mscorefonts-installer exfat-utils)

    echo ""
    echo ""
    echo "Updating package database..."
    sudo apt-get update

    for app in "${appList[@]}"
    do
    echo ""
    echo ""
    echo "Installing $app..."
    sudo apt-get -y install $app
    done

}

useLocalTime() {

    #Ubuntu maintains the hardware clock (RTC) in universal time (UTC).
    #The following command stores the hardware clock in local time to prevent time conflicts between Ubuntu and Windows.
    #Reboot after applying command.

    echo ""
    echo ""
    echo "Changing time from UTC to local time to fix time conflict with Windows..."
    timedatectl set-local-rtc 1 --adjust-system-clock

}

useUniversalTime() {

    #The following command resets the clock to universal time (UTC).
    #Reboot after applying command.

    echo ""
    echo ""
    echo "Changing time to universal time (UTC)..."
    timedatectl set-local-rtc 0

}



#Main Program
echo ""
echo "Please enter one of the following numbers to execute the script, or enter exit to close the script: "
echo ""
echo "1. Add Google and Microsoft Repositories"
echo "2. Install selected packages"
echo "3. Change time from UTC to local time to fix time conflict with Windows"
echo "4. Reset time to Ubuntu's universal time (UTC)"
echo "5. Suspend and hibernate PC after predetermined number of minutes"
echo ""
read -p "> " scriptPrompt

while [ $scriptPrompt != "exit" ]
do  
    if [ $scriptPrompt = "1" ]
    then
        addRepositories
    elif [ $scriptPrompt = "2" ]
    then
        installPackages
    elif [ $scriptPrompt = "3" ]
    then
        useLocalTime
    elif [ $scriptPrompt = "4" ]
    then
        useUniversalTime
    elif [ $scriptPrompt = "5" ]
    then
        enableHibernationAfterSleep
    elif [ $scriptPrompt != "exit" ]
    then
        echo ""
        echo "Error: Selected option is not valid!"
    fi

    echo ""
    echo "Please enter a number to execute the script or enter exit to close the script:"
    echo ""
    read -p "> " scriptPrompt
done

exit