# $1: name
# $2: key length
# $3: email
# $4: (bool = true) passphrase generate / TODO: (string) passphrase

if [[ -z $1 ]]; then
	exit 1
fi
gpg_name=$1

if [[ -z $2 ]]; then
	key_length=4096
else
	key_length=$2
fi

if [[ -z $3 ]]; then
	gpg_email=$GMAIL_LOGIN@$GMAIL_APPS_DOMAIN
else
	gpg_email=$3
fi

if [[ ! -z $4 ]]; then
	passphrase=$(generate_passphrase)
	passphrase_string="Passphrase: $passphrase"
fi

non_default_setting_needed GPG_KEY_RECIPIENT
sanei_install_dependencies mutt-gmail apt:rng-tools

rngd -f -r /dev/urandom &
RNGD_PID=$!

gpg_temp_dir="/root/.gpgkeys"
mkdir -p "$gpg_temp_dir"
chmod 700 "$gpg_temp_dir"
gpg_temp_path="$gpg_temp_dir/$gpg_name"

cat >"$gpg_temp_path" <<EOF
	%echo Generating a basic OpenGPG key
	Key-Type: RSA
	Key-Length: $key_length
	Subkey-Type: RSA
	Subkey-Length: 4096
	Name-Real: $gpg_name
	Name-Comment: $(date) @ $LOCAL_HOSTNAME
	Name-Email: $gpg_email
	Expire-Date: 0
	$passphrase_string
	%pubring $gpg_temp_path.pub.gpg
	%secring $gpg_temp_path.sec.gpg
	# Do a commit here, so that we can later print "done" :-)
	%commit
	%echo done
EOF

gpg --batch --gen-key "$gpg_temp_path"
kill $RNGD_PID
sleep 1

gpg --import "$gpg_temp_path.pub.gpg"
gpg --allow-secret-key-import --import "$gpg_temp_path.sec.gpg"

[[ $(gpg --no-default-keyring --keyring "${gpg_temp_path}.pub.gpg" --list-keys | grep '^pub') =~ 4096R\/([A-F0-9]*) ]]
# --secret-keyring ${gpg_temp_path}.sec.gpg --list-secret-keys

key_id=${BASH_REMATCH[1]}
mkdir -p "$GPG_KEY_ID_PATH"

gpg --fingerprint $key_id > "$gpg_temp_path.fingerprint"
echo $key_id > "$GPG_KEY_ID_PATH/$gpg_name"

echo $passphrase_string | mutt -F ~/.sanei/muttrc -a "$gpg_temp_path.sec.gpg" -a "$gpg_temp_path.pub.gpg" -s "GPG Key: $key_id for $gpg_name" -- $GPG_KEY_RECIPIENT < "$gpg_temp_path.fingerprint"
info "Generated key: $key_id"
rm -f "$gpg_temp_path"*
