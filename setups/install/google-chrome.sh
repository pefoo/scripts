#
# Install google chrome stable using the official deb package
#

# Already installed 
if command -v google-chrome-stable > /dev/null; then 
  echo 'Google chrome is already installed.'
  return 0
fi 

package_name="google-chrome-stable_current_amd64.deb"
wget https://dl.google.com/linux/direct/${package_name}

sudo apt install -qqy "./${package_name}"
rm "./${package_name}"

if ! command -v google-chrome-stable > /dev/null; then 
  echo "google-chrome-stable was not installed!"
  exit 1
fi 
echo 'Google chrome was successfully installed.'
