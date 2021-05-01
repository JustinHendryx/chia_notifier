#!/bin/bash
set -e

# Set where you have installed Chia and where this script can store some temporary files. Ensure the LOG_DIR exists before running the script
CHIA_DIR=/home/chia/chia-blockchain
LOG_DIR=/home/chia

# Telegram configuration for sending change notifications
# Obtain a token with these instructions: https://www.siteguarding.com/en/how-to-get-telegram-bot-api-token
# Obtain your chat ID with these instructions: https://stackoverflow.com/a/65946513
TELEGRAM_TOKEN="<fill this in>" 
TELEGRAM_CHAT_ID="<fill this in>"

# Defining what keys we care about in the output from `chia farm summary`
# You can add "Expected time to win" and other keys, but this will likely increase noise a bit
filter_keys () {
    grep -w -e "Farming status" -e "Total chia farmed" -e "Plot count"
}

# Derived configs - You probably do not need to change these
PREV_LOG_FILE=$LOG_DIR/previous_chia_summary.log
CURR_LOG_FILE=$LOG_DIR/current_chia_summary.log
TELEGRAM_URL="https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage"

# Enter Chia install directory and activate the Python venv
cd $CHIA_DIR
. ./activate

# Ensure we have our previous summary populated, since we assume it is present later on
if [ ! -f $PREV_LOG_FILE ]; then
    echo "Previous log file did not exist. Creating it and exiting early"
    chia farm summary | filter_keys > $PREV_LOG_FILE
    exit 0
fi

# Save the current summary into the log dir so we can compare it
echo "Saving current summary file into temporary file"
chia farm summary | filter_keys > $CURR_LOG_FILE

# Compare the two to see if anything has changed since the last run
if cmp -s $PREV_LOG_FILE $CURR_LOG_FILE; then
    echo "Nothing has changed since the last run"
else
    echo "Found differences since the last run. Sending Telegram notification..."
    # Call cURL with the appropate flags so it fails the script if the request fails, ensuring notifications are not lossy
    curl --silent --show-error --fail -X POST $TELEGRAM_URL -d chat_id=$TELEGRAM_CHAT_ID --data-urlencode "text@${CURR_LOG_FILE}"
fi

# Promote the current state to previous state in preparation for the next run
mv $CURR_LOG_FILE $PREV_LOG_FILE

exit 0
