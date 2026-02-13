#!/bin/bash

# Utility functions for frequently performed tasks
# This file MUST NOT contain anything other than function definitions.

echo_red_text() {
	echo -e "\033[31m$1\033[0m"
}

echo_green_text() {
	echo -e "\033[32m$1\033[0m"
}
