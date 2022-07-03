#chrome 
wget -q -O https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-get add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
sudo atp-get update
sudo apt-get install google-chrome-stable -y

#git
sudo apt-get install git -y

#kduff3
sudo apt-get install kdiff3

#nodejs & npm
sudo apt-get install nodejs -y
sudo apt-get install npm -y

#dotnet
#FIXME https://docs.microsoft.com/ru-ru/dotnet/core/install/linux-ubuntu#apt-troubleshooting
sudo apt-get install apt-transport-https -y
sudo apt-get update
sudo apt-get install dotnet-sdk-6.0 -y
