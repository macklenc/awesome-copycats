#! /bin/bash

# Adapted from copycat-killer's "switch-theme" (cleanup, enhancements and switch to bash/Linux)
# Bash script created by Chris Macklen

# Awesome Copycats switch theme script
# It also updates to latest commit.

DESTDIR=~/.config/awesome
ORIGPROJECT=copycat-killer/awesome-copycats
PROJECT=macklenc/awesome-copycats
n_themes=$(find -name rc.\*.lua | wc -l)
restartA=0
num=0
str=""

# -------------------------------------------------------------------------
#   Decoding options
# -------------------------------------------------------------------------
USAGE="Usage: $0 [-h(elp)] | [-r(estart Awesome)] | [-n(choice number)] [-s(choice string)]"

while [ $# -gt 0 ]; do
   case "$1" in
      "-h" )
	 echo $USAGE
	 exit
	 ;;
      "-r" )
	 restartA=1
	 ;;
      "-n" )
	 num=$2
	 shift
	 ;;
      "-s" )
	 str=$2
	 shift
	 ;;
      * )
	 echo $USAGE
	 exit
	 ;;
   esac
   shift
done


swap_dialog(){
   echo
   echo "see https://github.com/$ORIGPROJECT and https://github.com/$PROJECT"
   find -name rc.\*.lua | sed 's/ /\n/g;s/\.\///g' | cat -n
   read -p "Switch to theme: " num
   swap_cmd $num
}

swap_cmd(){
   num=$1
   if [ ! -z $num -a $num -ge 1 -a $num -le $n_themes ] ; then
      NEW_THEME=$(find -name rc.\*.lua | head -n $num | tail -n 1)
      swap_name $NEW_THEME
   else echo " !! Aborted. " ; fi
}

swap_name(){
   NEW_THEME=$1
   cp $NEW_THEME rc.lua
   echo -e "\nTheme is now $NEW_THEME"
}

restart_awesome(){
   pkill -HUP awesome
}

cd $DESTDIR && echo -n $(git pull)
git submodule init
git submodule update

if [ $num -ne 0 ] ; then
   swap_cmd $swap
elif [ ! -z $str ] ; then
   swap_name $str
else
   swap_dialog
fi
if [ $restartA -eq 1 ] ; then
   restart_awesome
fi
exit
