#!/bin/bash
## BEGIN INIT INFO
# Provides: twistd
# Default-Start: 3 4 5
# Default-Stop: 0 1 2 3 4 6
# Required-Start:
#
## END INIT INFO
# sandbox:        Set up / mountpoint to be shared, /var/tmp, /tmp, /home/sandbox unshared
#
# chkconfig: 345 1 99
#
# description: sandbox, xguest and other apps that want to use pam_namespace \
#              require this script be run at boot.  This service script does \
#              not actually run any service but sets up: \
#              /var/tmp, /tmp and home directories to be used by these tools.\
#              If you do not use sandbox, xguest or pam_namespace you can turn \
#              this service off.\
#

# Source function library.
. /etc/init.d/functions

HOMEDIRS="/home"

. /etc/sysconfig/sandbox

LOCKFILE=/var/lock/subsys/sandbox

base=${0##*/}

start() {
    echo -n "Starting sandbox"

    [ -f "$LOCKFILE" ] && return 1

    touch $LOCKFILE
    mount --make-rshared / || return $? 
    mount --rbind /tmp /tmp || return $?
    mount --rbind /var/tmp /var/tmp || return $?
    mount --make-private /tmp || return $?
    mount --make-private /var/tmp || return $?
    for h in $HOMEDIRS; do
        mount --rbind $h $h || return $?
        mount --make-private $h || return $?
    done

    return 0
}

stop() {
    echo -n "Stopping sandbox"

    [ -f "$LOCKFILE" ] || return 1
}

status() {
    if [ -f "$LOCKFILE" ]; then 
        echo "$base is running"
    else
        echo "$base is stopped"
    fi
    exit 0
}

case "$1" in
    restart)
        stop
        start
        ;;

    start)
        start
        ;;

    stop)
        stop
        ;;

    status)
        status
        ;;

    *)
        echo $"Usage: $0 {start|stop|status|restart}"
        exit 1
        ;;
esac

exit $?
