alias createFunction='
FUNCTION="/tmp/fnt/fn.sh"
nano $FUNCTION
chmod +x $FUNCTION
sudo $FUNCTION
rm -f $FUNCTION
'

alias editFunction='
mkdir -p /tmp/fnt && FUNCTION="/tmp/fnt/fn.sh" && rm -f $FUNCTION
nano $FUNCTION
chmod +x $FUNCTION
sudo $FUNCTION
'
