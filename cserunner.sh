#!/bin/bash

echo "
  ____ ____  _____   ____                              
 / ___/ ___|| ____| |  _ \ _   _ _ __  _ __   ___ _ __ 
| |   \___ \|  _|   | |_) | | | | '_ \| '_ \ / _ \ '__|
| |___ ___) | |___  |  _ <| |_| | | | | | | |  __/ |   
 \____|____/|_____| |_| \_\\\__,_|_| |_|_| |_|\___|_|   
                                by @Bojin Li"


# if have input from command line
if [ $# -gt 0 ]
    then
        COMMAND=$*
        echo "Command: $COMMAND"
    else
        echo -n "Enter command: "
        read COMMAND
fi

# ask for username
echo -n "Enter zid: "
read USERNAME
# ask for password
echo -n "Enter password: "
read -s PASSWORD

SSH_HOST="cse.unsw.edu.au"
WORKING_DIRECTORY="~/cserunner/tmp"

echo
echo "####Checking local environment####"
# check if expect is installed
if ! [ -x "$(command -v expect)" ]; then
    echo "Expect command is not installed. Installing..."
    if [ "$(uname)" == "Darwin" ]; then
        # check if brew is installed
        if ! [ -x "$(command -v brew)" ]; then
            echo "Homebrew is not installed. Installing..."
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        fi
        brew install expect
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        sudo apt-get install expect
    else
        echo "Unsupported OS"
        exit 1
    fi
else
    echo "Awesome! Expect command is installed."
fi


echo
echo "#######Checking remote host#######"
expect << EOF
spawn ssh "$USERNAME@$SSH_HOST" "test -d $WORKING_DIRECTORY && echo All good! || mkdir -p $WORKING_DIRECTORY"
expect {
"yes/no" {send "yes\r"; exp_continue}
"password" {send "$PASSWORD\r"}
}
expect eof
EOF

echo
echo "##########Copying files##########"
expect << EOF
spawn bash -c "scp $(pwd)/* $USERNAME@$SSH_HOST:$WORKING_DIRECTORY"
expect {
"yes/no" {send "yes\r"; exp_continue}
"password" {send "$PASSWORD\r"}
}
expect eof
EOF

echo
echo "########Executing command########"
expect << EOF
spawn ssh "$USERNAME@$SSH_HOST" "cd $WORKING_DIRECTORY && $COMMAND"
expect {
"yes/no" {send "yes\r"; exp_continue}
"password" {send "$PASSWORD\r"}
}
expect eof
EOF
