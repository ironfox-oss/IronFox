#!/bin/bash

libclang=""
if grep -q "Fedora" /etc/os-release; then
    libclang="/usr/lib64"
else
    libclang="/usr/lib/x86_64-linux-gnu"
fi

export libclang