#!bin/sh
echo 'intsall latest lazydocker from source'
echo 'no need for admin'
read "Press any key to continue . . ."

# get current ver
LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
# pull down latest
curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
# temp staging
mkdir lazydocker-temp
# untar
tar xf lazydocker.tar.gz -C lazydocker-temp
# stick it in ust bin
sudo mv lazydocker-temp/lazydocker /usr/local/bin
# test
lazydocker --version
# cleanup
rm -rf lazydocker.tar.gz lazydocker-temp

# run?
echo 'complete'
echo 'actual run will need docker permissions'
echo 'or sudo of course'
echo ''
echo 'just call lazydocker by name:'
echo 'user@host:~# sudo lazydocker'
read "Press any key to exit . . ."
exit
