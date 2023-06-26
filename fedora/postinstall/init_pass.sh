gpg2 --import $1
git clone $2 ~/.password-store
chown -R $USER ~/.gnupg
chmod 700 ~/.gnupg
