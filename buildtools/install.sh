# A shell script to install dependencies which is used when building the script

echo Pre Installation

sudo apt install build-essential libreadline-dev

echo Installing lua...
curl -R -O http://www.lua.org/ftp/lua-5.1.3.tar.gz
tar -zxf lua-5.1.3.tar.gz
cd lua-5.1.3
make linux test
sudo make install

lua --version

cd ..

echo Installing luarocks...
wget https://luarocks.org/releases/luarocks-3.3.1.tar.gz
tar zxpf luarocks-3.3.1.tar.gz
cd luarocks-3.3.1
./configure --with-lua-include=/usr/local/include
make
sudo make install

luarocks --version

cd ..

sudo luarocks install metalua-compiler
sudo luarocks install penlight
sudo luarocks install checks

echo Installing main dependencies...

sudo luarocks install formatter

echo Cleaning up...

rm lua-5.1.3.tar.gz
rm luarocks-3.3.1.tar.gz
