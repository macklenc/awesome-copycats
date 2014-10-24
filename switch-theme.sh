#! /bin/bash

# Awesome Copycats switch theme script
# It also updates to latest commit.

DESTDIR=~/.config/awesome
PROJECT=macklenc/awesome-copycats
n_themes=$(find -name rc.\*.lua | wc -l)
restartA=0
swap=0
# swap_dialog

swap_dialog(){
   echo
   echo "see https://github.com/$PROJECT"
   find -name rc.\*.lua | sed 's/ /\n/g;s/\.\///g' | cat -n
   read -p "Switch to theme: " num
   swap_cmd $num
}

swap_cmd(){
   num=$1
   if [ ! -z $num -a $num -ge 1 -a $num -le $n_themes ] ; then
      NEW_THEME=$(find -name rc.\*.lua | head -n $num | tail -n 1)
      cp $NEW_THEME rc.lua
	  echo -e "\nTheme is now $NEW_THEME"
  else echo " !! Aborted. " ; fi
}

restart_awesome(){
   #echo 'awesome.restart()' | awesome-client 2>&1 > /dev/null
   pkill -HUP awesome
}

cd $DESTDIR && echo -n $(git pull)
git submodule init
git submodule update
for arg in "$@"
do
   if [ "$arg" == "-r" ] ; then
      restartA=1
   else
      swap=$arg
   fi
done
if [ $swap -ne 0 ] ; then
   swap_cmd $swap
else
   swap_dialog
fi
if [ $restartA -eq 1 ] ; then
   restart_awesome
fi
exit
