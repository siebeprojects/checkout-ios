#!/bin/bash

# Format: get_branch_name.sh <github.event_name> <github.head_ref> <github.ref_name>

event_name=$1
head_ref=$2
ref=$3

if [ "$event_name" = "pull_request" ]
then
    branch_name=$head_ref
else
    branch_name=$ref
fi

echo -n "::set-output name=safe-branch-name::"
echo "${branch_name/[^[:alnum:]-]/_}"