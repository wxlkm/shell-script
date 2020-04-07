#!/bin/sh
#
#     RedHat system statup script for Jenkins
#     Based on SUSE system statup script for Jenkins
#     Copyright (C) 2007  Pascal Bleser
#
#     This library is free software; you can redistribute it and/or modify it
#     under the terms of the GNU Lesser General Public License as published by
#     the Free Software Foundation; either version 2.1 of the License, or (at
#     your option) any later version.
#
#     This library is distributed in the hope that it will be useful, but
#     WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#     Lesser General Public License for more details.
#
#     You should have received a copy of the GNU Lesser General Public
#     License along with this library; if not, write to the Free Software
#     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
#     USA.
#
###############################################################################
#
# chkconfig: 35 99 01
# description: Jenkins Automation Server
#
###############################################################################
### BEGIN INIT INFO
# Provides:          jenkins
# Required-Start:    $local_fs $remote_fs $network $time $named
# Should-Start: $time sendmail
# Required-Stop:     $local_fs $remote_fs $network $time $named
# Should-Stop: $time sendmail
# Default-Start:     3 5
# Default-Stop:      0 1 2 6
# Short-Description: Jenkins Automation Server
# Description:       Jenkins Automation Server
### END INIT INFO

# Check for missing binaries (stale symlinks should not happen)
JENKINS_WAR="/usr/lib/jenkins/jenkins.war"
test -r "$JENKINS_WAR" || { echo "$JENKINS_WAR not installed";
	if [ "$1" = "stop" ]; then exit 0;
	else exit 5; fi; }

# Check for existence of needed config file and read it
JENKINS_CONFIG=/etc/sysconfig/jenkins
test -e "$JENKINS_CONFIG" || { echo "$JENKINS_CONFIG not existing";
	if [ "$1" = "stop" ]; then exit 0;
	else exit 6; fi; }
test -r "$JENKINS_CONFIG" || { echo "$JENKINS_CONFIG not readable. Perhaps you forgot 'sudo'?";
	if [ "$1" = "stop" ]; then exit 0;
	else exit 6; fi; }

JENKINS_PID_FILE="/var/run/jenkins.pid"
JENKINS_LOCKFILE="/var/lock/subsys/jenkins"

# Source function library.
. /etc/init.d/functions

# Read config
[ -f "$JENKINS_CONFIG" ] && . "$JENKINS_CONFIG"

# Set up environment accordingly to the configuration settings
[ -n "$JENKINS_HOME" ] || { echo "JENKINS_HOME not configured in $JENKINS_CONFIG";
	if [ "$1" = "stop" ]; then exit 0;
	else exit 6; fi; }
[ -d "$JENKINS_HOME" ] || { echo "JENKINS_HOME directory does not exist: $JENKINS_HOME";
	if [ "$1" = "stop" ]; then exit 0;
	else exit 1; fi; }

# Search usable Java as /usr/bin/java might not point to minimal version required by Jenkins.
# see http://www.nabble.com/guinea-pigs-wanted-----Hudson-RPM-for-RedHat-Linux-td25673707.html
candidates="
/etc/alternatives/java
/usr/lib/jvm/java-1.8.0/bin/java
/usr/lib/jvm/jre-1.8.0/bin/java
/usr/lib/jvm/java-1.7.0/bin/java
/usr/lib/jvm/jre-1.7.0/bin/java
/usr/lib/jvm/java-11.0/bin/java
/usr/lib/jvm/jre-11.0/bin/java
/usr/lib/jvm/java-11-openjdk-amd64
/usr/bin/java
"
for candidate in $candidates
do
  [ -x "$JENKINS_JAVA_CMD" ] && break
  JENKINS_JAVA_CMD="$candidate"
done

JAVA_CMD="$JENKINS_JAVA_CMD $JENKINS_JAVA_OPTIONS -DJENKINS_HOME=$JENKINS_HOME -jar $JENKINS_WAR"
PARAMS="--logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war --daemon"
[ -n "$JENKINS_PORT" ] && PARAMS="$PARAMS --httpPort=$JENKINS_PORT"
[ -n "$JENKINS_LISTEN_ADDRESS" ] && PARAMS="$PARAMS --httpListenAddress=$JENKINS_LISTEN_ADDRESS"
[ -n "$JENKINS_HTTPS_PORT" ] && PARAMS="$PARAMS --httpsPort=$JENKINS_HTTPS_PORT"
[ -n "$JENKINS_HTTPS_KEYSTORE" ] && PARAMS="$PARAMS --httpsKeyStore=$JENKINS_HTTPS_KEYSTORE"
[ -n "$JENKINS_HTTPS_KEYSTORE_PASSWORD" ] && PARAMS="$PARAMS --httpsKeyStorePassword='$JENKINS_HTTPS_KEYSTORE_PASSWORD'"
[ -n "$JENKINS_HTTPS_LISTEN_ADDRESS" ] && PARAMS="$PARAMS --httpsListenAddress=$JENKINS_HTTPS_LISTEN_ADDRESS"
[ -n "$JENKINS_HTTP2_PORT" ] && PARAMS="$PARAMS --http2Port=$JENKINS_HTTP2_PORT"
[ -n "$JENKINS_HTTP2_LISTEN_ADDRESS" ] && PARAMS="$PARAMS --http2ListenAddress=$JENKINS_HTTP2_LISTEN_ADDRESS"
[ -n "$JENKINS_DEBUG_LEVEL" ] && PARAMS="$PARAMS --debug=$JENKINS_DEBUG_LEVEL"
[ -n "$JENKINS_HANDLER_STARTUP" ] && PARAMS="$PARAMS --handlerCountStartup=$JENKINS_HANDLER_STARTUP"
[ -n "$JENKINS_HANDLER_MAX" ] && PARAMS="$PARAMS --handlerCountMax=$JENKINS_HANDLER_MAX"
[ -n "$JENKINS_HANDLER_IDLE" ] && PARAMS="$PARAMS --handlerCountMaxIdle=$JENKINS_HANDLER_IDLE"
[ -n "$JENKINS_EXTRA_LIB_FOLDER" ] && PARAMS="$PARAMS --extraLibFolder=$JENKINS_EXTRA_LIB_FOLDER"
[ -n "$JENKINS_ARGS" ] && PARAMS="$PARAMS $JENKINS_ARGS"

if [ "$JENKINS_ENABLE_ACCESS_LOG" = "yes" ]; then
    PARAMS="$PARAMS --accessLoggerClassName=winstone.accesslog.SimpleAccessLogger --simpleAccessLogger.format=combined --simpleAccessLogger.file=/var/log/jenkins/access_log"
fi

RETVAL=0

case "$1" in
    start)
	echo -n "Starting Jenkins "
	daemon --user "$JENKINS_USER" --pidfile "$JENKINS_PID_FILE" $JAVA_CMD $PARAMS > /dev/null
	RETVAL=$?
	if [ $RETVAL = 0 ]; then
	    success
	    echo > "$JENKINS_PID_FILE"  # just in case we fail to find it
            MY_SESSION_ID=`/bin/ps h -o sess -p $$`
            # get PID
            /bin/ps hww -u "$JENKINS_USER" -o sess,ppid,pid,cmd | \
            while read sess ppid pid cmd; do
		[ "$ppid" = 1 ] || continue
		# this test doesn't work because Jenkins sets a new Session ID
                # [ "$sess" = "$MY_SESSION_ID" ] || continue
	       	echo "$cmd" | grep $JENKINS_WAR > /dev/null
		[ $? = 0 ] || continue
		# found a PID
		echo $pid > "$JENKINS_PID_FILE"
	    done
	    touch $JENKINS_LOCKFILE
	else
	    failure
	fi
	echo
	;;
    stop)
	echo -n "Shutting down Jenkins "
	killproc jenkins
	rm -f $JENKINS_LOCKFILE
	RETVAL=$?
	echo
	;;
    try-restart|condrestart)
	if test "$1" = "condrestart"; then
		echo "${attn} Use try-restart ${done}(LSB)${attn} rather than condrestart ${warn}(RH)${norm}"
	fi
	$0 status
	if test $? = 0; then
		$0 restart
	else
		: # Not running is not a failure.
	fi
	;;
    restart)
	$0 stop
	$0 start
	;;
    force-reload)
	echo -n "Reload service Jenkins "
	$0 try-restart
	;;
    reload)
    	$0 restart
	;;
    status)
    	status jenkins
	RETVAL=$?
	;;
    probe)
	## Optional: Probe for the necessity of a reload, print out the
	## argument to this init script which is required for a reload.
	## Note: probe is not (yet) part of LSB (as of 1.9)

	test "$JENKINS_CONFIG" -nt "$JENKINS_PID_FILE" && echo reload
	;;
    *)
	echo "Usage: $0 {start|stop|status|try-restart|restart|force-reload|reload|probe}"
	exit 1
	;;
esac
exit $RETVAL
