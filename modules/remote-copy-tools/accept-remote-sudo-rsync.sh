filename="/etc/sudoers.d/${PARENT_USERNAME}"
echo "$PARENT_USERNAME ALL=(ALL) NOPASSWD: /usr/bin/rsync" > "$filename"
chmod 0440 "$filename"
chown root:root "$filename"
