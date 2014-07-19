# OpenVPN (simple)
# =================
# .. module:: openvpn-simple
#    :synopsis: OpenVPN with a simple configuration.
#    :platform: trusty
# .. moduleauthor:: Bazyli Brzoska <bazyli.brzoska@gmail.com>
#
# Module
# ++++++
#
# :Description: TODO
#
# Code
# ++++

# apt_install "oracle-java8-installer" "ppa:webupd8team/java"
apt-get install openvpn bridge-utils easy-rsa
mkdir /etc/openvpn/easy-rsa/ 
cp -R /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/ 
#mcedit /etc/openvpn/easy-rsa/vars
chown -R root:admin /etc/openvpn/easy-rsa
chmod g+w /etc/openvpn/easy-rsa
source ./vars
./clean-all  ## Setup the easy-rsa directory (Deletes all keys)
./build-dh  ## takes a while consider backgrounding
./pkitool --initca ## creates ca cert and key
./pkitool --server server ## creates a server cert and key
cd keys
openvpn --genkey --secret ta.key  ## Build a TLS key
cp server.crt server.key ca.crt dh2048.pem ta.key ../../
