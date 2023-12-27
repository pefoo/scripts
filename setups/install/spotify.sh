#
# Install spotify
#

if command -v spotify > /dev/null; then 
  echo 'Spotify is already installed.'
  exit 0
fi

if ! command -v curl > /dev/null; then 
  apt-get install -qqy curl 
fi

curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update -qq && sudo apt-get install -qqy spotify-client

if ! command -v spotify > /dev/null; then 
  echo "Spotify was not installed"
  exit 1
fi
echo 'Spotify was successfully installed.'
