#!/bin/bash

echo "
  ____ ____  _____   ____                              
 / ___/ ___|| ____| |  _ \ _   _ _ __  _ __   ___ _ __ 
| |   \___ \|  _|   | |_) | | | | '_ \| '_ \ / _ \ '__|
| |___ ___) | |___  |  _ <| |_| | | | | | | |  __/ |   
 \____|____/|_____| |_| \_\\\__,_|_| |_|_| |_|\___|_|   
                                by @Bojin Li"


USERNAME="z5111111"
SSH_HOST="cse.unsw.edu.au"
WORKING_DIRECTORY="~/cserunner/tmp"
PASSWORD="zpassword"

if [ $# -eq 0 ]; then
    echo "Usage: ./cserun.sh <command>"
    echo "Example: ./cserun.sh 2041 classrun -sturec"
    exit 1
fi

echo
echo "🔥 Check Dependencies: "
echo -ne "\t🔎 Checking Local..."
# check if sshpass is installed
if ! [ -x "$(command -v sshpass)" ]; then
    echo -e "\r\t🟠 Installing sshpass..."
    if [ "$(uname)" == "Darwin" ]; then
        # check if brew is installed
        if ! [ -x "$(command -v brew)" ]; then
            echo "\t⚠ Homebrew is not installed. Installing..."
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        fi
        curl -L https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb > sshpass.rb
        brew install sshpass.rb
        rm sshpass.rb
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        sudo apt-get install sshpass
    else
        echo -e "\r\t⛔ Unsupported OS ($(uname -s))"
        exit 1
    fi
    echo -e "\r\t✅ Sshpass Install Success"
else
    sleep 2
    echo -e "\r\t✅ Local Dependent Environment Checked."
fi

echo -ne "\t🔎 Checking Remote..."
sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $USERNAME@$SSH_HOST "test -d $WORKING_DIRECTORY || mkdir -p $WORKING_DIRECTORY"
sleep 2
echo -e "\r\t✅ Remote Dependent Environment Checked."

sleep 1
echo "⚡ Synchronization: "
sleep 1
echo -e "\t🔎 Syncing Files to Remote..."
sshpass -p $PASSWORD scp $(pwd)/* $USERNAME@$SSH_HOST:$WORKING_DIRECTORY
for file in $(ls); do
    echo -e "\t✅ $file"
    sleep 0.5
done

echo
echo "🚀🚀🚀🚀🚀🚀🚀 Executing Command 🚀🚀🚀🚀🚀🚀🚀"
echo
sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $USERNAME@$SSH_HOST "cd $WORKING_DIRECTORY && $*"
