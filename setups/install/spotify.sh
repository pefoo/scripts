#
# Install spotify
#

if command -v spotify > /dev/null; then 
  return 0
fi

if ! command -v curl > /dev/null; then 
  apt-get install -qqy curl 
fi

curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add - 
cho "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update -qq && sudo apt-get install -qqy spotify-client

if ! command -v spotify > /dev/null; then 
  echo "Spotify was not installed"
  exit 1
fi
