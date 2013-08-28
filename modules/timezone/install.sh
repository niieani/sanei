# TODO: setup should now ask to customize settings
# TODO: ask for timezone
echo "$TIMEZONE" | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata

set_installed timezone