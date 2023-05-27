sudo apt -qq install -y libxcb-xinerama0 jq git wget
mkdir .bitcoin
cat << EOF > .bitcoin/bitcoin.conf
server=1
listen=1
mempoolfullrbf=1
onlynet=onion
debug=tor
EOF
torsocks wget https://bitcoincore.org/bin/bitcoin-core-24.0.1/bitcoin-24.0.1-x86_64-linux-gnu.tar.gz
torsocks wget https://bitcoincore.org/bin/bitcoin-core-24.0.1/SHA256SUMS
torsocks wget https://bitcoincore.org/bin/bitcoin-core-24.0.1/SHA256SUMS.asc
sha256sum --ignore-missing --check SHA256SUMS
#gpg --keyserver hkps://keys.openpgp.org --recv-keys E777299FC265DD04793070EB944D35F9AC3DB76A
gpg --verify SHA256SUMS.asc
torsocks git clone https://github.com/bitcoin-core/guix.sigs
sudo adduser "$USER" debian-tor
torsocks git clone https://github.com/bitcoin-core/guix.sigs
cd guix.sigs/builder-keys/
gpg --import *
cd ../..
ls
gpg --verify SHA256SUMS.asc
gpg --verify SHA256SUMS.asc | grep Good
gpg --verify SHA256SUMS.asc | grep "Good signature"
gpg --verify SHA256SUMS.asc 2>/dev/null
gpg --list-keys
gpg --edit-key
#gpg --edit-key E777299FC265DD04793070EB944D35F9AC3DB76A
gpg --verify SHA256SUMS.asc
gpg --help
gpg --check-signatures
gpg --verify SHA256SUMS.asc
gpg --help
gpg --verify SHA256SUMS.asc > gpgtest
grep Good gpgtest 
cat gpgtest 
gpg --verify SHA256SUMS.asc &>gpgtest
cat gpgtest 
grep Good gpgtest 
