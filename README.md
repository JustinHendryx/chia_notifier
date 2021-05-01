# Chia Notifier
Simple shell script cron to alert you via Telegram when your Chia farmer state changes.

## Requirements
Your farmer should be running GNU/Linux and Chia should have been installed roughly as specified in the official docs, as a Python venv is assumed used.

## How to use
1. Place the script somewhere on your Chia farmer's disk.

2. Populate the Telegram configuration using the instructions in the shell script using your favorite editor.

3. Add the script into your Chia user's crontab. For example, every ten minutes.
`crontab -e`

Add the following entry:
`*/10 * * * * sh /path/to/the/script.sh`

## Testing
If you are unsure if the script is working properly, run it once manually to ensure the initial state is populated, then modify the previous_chia_summary.log file in the LOG_DIR directory. Once you have modified this file, run the script again. It should detect a change and you will get an alert if things are configured correctly.
