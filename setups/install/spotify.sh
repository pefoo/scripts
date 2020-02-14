#
# Install spotify
#

if command -v spotify > /dev/null; then 
  exit 0
fi

# Add spotify repository key 
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90
# Add spotify repository 
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt update -qq 
sudo apt install -y spotify-client 

if ! command -v spotify > /dev/null; then 
  echo "Spotify was not installed"
  exit 1
fi
