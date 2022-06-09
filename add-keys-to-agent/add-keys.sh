#!/bin/sh
blacklist="/home/$(logname)/.add-keys/blacklist"

if [ ! -s "$blacklist" ]
then
    touch "$blacklist"
fi

keys_in_folder=$(ls ~/.ssh/id* | grep -v '\.pub$' | grep -vFxf "$blacklist" | tr '\n' ' ' | xargs)

num_keys_in_agent=$(ssh-add -l | wc -l)
num_keys_in_folder=$(echo "$keys_in_folder" | wc -w)

if [ "$num_keys_in_agent" -ne "$num_keys_in_folder" ]
then

    ssh-add -D
    delete_exit=$?

    for key in $keys_in_folder
    do
        ssh-add "$key"
    done

    add_exit=$?

    combined_exits=$((delete_exit+add_exit))

    if [ "$combined_exits" -eq 0 ]
    then
        exit 0
    else
        echo 'ssh keys not added successfully'
        exit 1
    fi

else

    exit 0

fi
