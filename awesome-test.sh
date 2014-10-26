#!/bin/bash

function usage()
{
  cat <<USAGE
Usage: $0 [start|stop|restart] | [-r(un command) "command"] | [-c(onfig file "path")]

  start    Start nested Awesome in Xephyr
  stop     Stop Xephyr
  restart  Reload nested Awesome configuration
  -r       Run command in nested Awesome
  -c	   Run with selected config file

USAGE
  exit 0
}

# WARNING: the following two functions expect that you only run one instance
# of Xephyr and the last launched Awesome runs in it

function awesome_pid()
{
  /bin/pidof awesome | cut -d\  -f1
}

function xephyr_pid()

{
  /bin/pidof Xephyr | cut -d\  -f1
}

[ $# -lt 1 ] && usage

# If rc.lua.new is missing, make a default one.
RC_LUA=~/.config/awesome/rc.lua.test
test -f $RC_LUA || /bin/cp /etc/xdg/awesome/rc.lua $RC_LUA

# Just in case we're not running from /usr/bin
AWESOME=`which awesome  | sed 's/awesome is //g'`
XEPHYR=`which Xephyr  | sed 's/Xephyr is //g'`

test -x $AWESOME || { echo "Awesome executable not found. Please install Awesome"; exit 1; }
test -x $XEPHYR || { echo "Xephyr executable not found. Please install Xephyr"; exit 1; }

starta=0
stopa=0
restarta=0
run=""
config=""


function start_awesome(){
   DISPLAY=:0 $XEPHYR -ac -br -noreset -screen 1400x1050 :1 & > /dev/null  2>&1
   sleep 1
   #DISPLAY=:1.0 $AWESOME -c $RC_LUA &
   DISPLAY=:1.0 $AWESOME -c $1 & > /dev/null 2>&1
   sleep 1
   echo Awesome ready for tests. PID is $(awesome_pid)
   DISPLAY=:0
}

function stop_awesome(){
   echo -n "Stopping Nested Awesome... "
   if [ -z $(xephyr_pid) ]; then
      echo "Not running: not stopped :)"
      exit 0
   else
      kill $(xephyr_pid)
      echo "Done."
   fi
}

function restart_awesome(){
   echo -n "Restarting Awesome... "
   kill -s SIGHUP $(awesome_pid)
}

function run_command(){
   DISPLAY=:1.0 "$1" &
   DISPLAY=:0
}

while [ $# -gt 0 ]; do
   case "$1" in
   start)
      starta=1
      ;;
   stop)
      stopa=1
      ;;
   restart)
      restarta=1
      ;;
   "-r")
      shift
      run= "$1"
      ;;
   "-c")
      shift
      config="$1"
      ;;
   *)
      usage
      ;;
   esac
   shift
done

if [ $starta -eq 1 ] ; then
   if [ ! -z $config ] ; then
      start_awesome $config
   else
      start_awesome $RC_LUA
   fi
fi

if [ $restarta -eq 1 ] ; then
   restart_awesome
fi

if [ $stopa -eq 1 ] ; then
   stop_awesome
fi

if [ ! -z $run ] ; then
   run_command $run
fi
