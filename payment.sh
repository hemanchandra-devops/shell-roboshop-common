#!/bin/bash

source ./common.sh
app_name=payment

checkroot
app_setup
python_setup
systemd_setup
restart