# -----------------------------------------------------------------------------
# Control Script for the CATALINA Server
#
# Environment Variable Prerequisites
#
#   Suggest to put the variables below into a script 
#   setenv.sh in CATALINA_BASE/bin to keep your customizations separate.
#
#   CATALINA_HOME   May point at your Catalina "build" directory.
#
#   CATALINA_BASE   (Optional) Base directory for resolving dynamic portions
#                   of a Catalina installation.  If not present, resolves to
#                   the same directory that CATALINA_HOME points to.
#
#   CATALINA_OUT    (Optional) Full path to a file where stdout and stderr
#                   will be redirected.
#                   Default is $CATALINA_BASE/logs/catalina.out
#
#   CATALINA_OPTS   (Optional) Java runtime options used when the "start",
#                   "run" or "debug" command is executed.
#                   Include here and not in JAVA_OPTS all options, that should
#                   only be used by Tomcat itself, not by the stop process,
#                   the version command etc.
#                   Examples are heap size, GC logging, JMX ports etc.
#
#   CATALINA_TMPDIR (Optional) Directory path location of temporary directory
#                   the JVM should use (java.io.tmpdir).  Defaults to
#                   $CATALINA_BASE/temp.
#
#   JAVA_HOME       Must point at your Java Development Kit installation.
#                   Required to run the with the "debug" argument.
#
#   JRE_HOME        Must point at your Java Runtime installation.
#                   Defaults to JAVA_HOME if empty. If JRE_HOME and JAVA_HOME
#                   are both set, JRE_HOME is used.
#
#   JAVA_OPTS       (Optional) Java runtime options used when any command
#                   is executed.
#                   Include here and not in CATALINA_OPTS all options, that
#                   should be used by Tomcat and also by the stop process,
#                   the version command etc.
#                   Most options should go into CATALINA_OPTS.
#
#   JAVA_ENDORSED_DIRS (Optional) Lists of of colon separated directories
#                   containing some jars in order to allow replacement of APIs
#                   created outside of the JCP (i.e. DOM and SAX from W3C).
#                   It can also be used to update the XML parser implementation.
#                   Defaults to $CATALINA_HOME/endorsed.
#
#   JPDA_TRANSPORT  (Optional) JPDA transport used when the "jpda start"
#                   command is executed. The default is "dt_socket".
#
#   JPDA_ADDRESS    (Optional) Java runtime options used when the "jpda start"
#                   command is executed. The default is localhost:8000.
#
#   JPDA_SUSPEND    (Optional) Java runtime options used when the "jpda start"
#                   command is executed. Specifies whether JVM should suspend
#                   execution immediately after startup. Default is "n".
#
#   JPDA_OPTS       (Optional) Java runtime options used when the "jpda start"
#                   command is executed. If used, JPDA_TRANSPORT, JPDA_ADDRESS,
#                   and JPDA_SUSPEND are ignored. Thus, all required jpda
#                   options MUST be specified. The default is:
#
#                   -agentlib:jdwp=transport=$JPDA_TRANSPORT,
#                       address=$JPDA_ADDRESS,server=y,suspend=$JPDA_SUSPEND
#
#   JSSE_OPTS       (Optional) Java runtime options used to control the TLS
#                   implementation when JSSE is used. Default is:
#                   "-Djdk.tls.ephemeralDHKeySize=2048"
#
#   CATALINA_PID    (Optional) Path of the file which should contains the pid
#                   of the catalina startup java process, when start (fork) is
#                   used
#
#   LOGGING_CONFIG  (Optional) Override Tomcat's logging config file
#                   Example (all one line)
#                   LOGGING_CONFIG="-Djava.util.logging.config.file=$CATALINA_BASE/conf/logging.properties"
#
#   LOGGING_MANAGER (Optional) Override Tomcat's logging manager
#                   Example (all one line)
#                   LOGGING_MANAGER="-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager"
#
#   USE_NOHUP       (Optional) If set to the string true the start command will
#                   use nohup so that the Tomcat process will ignore any hangup
#                   signals. Default is "false" unless running on HP-UX in which
#                   case the default is "true"
# -----------------------------------------------------------------------------

# 设置JAVA_HOME
export JAVA_HOME=/usr/local/jdk1.8.0_201
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=$JAVA_HOME/lib

# 参考地址: https://blog.csdn.net/y_blueblack/article/details/81066141
# -Xms：虚拟机初始化时的最小堆内存。
# -Xmx：虚拟机可使用的最大堆内存. -Xms与-Xmx设成一样的值，避免JVM因为频繁的GC导致性能大起大落
# 设定每个线程的堆栈大小。一般不宜设置超过1M，要不然容易出现out ofmemory
# AggressiveOpts: 启用这个参数，则每当JDK版本升级时，你的JVM都会使用最新加入的优化技术（如果有的话）
# UseBiasedLocking: 启用一个优化了的线程锁。对于应用服务器来说每个http请求就是一个线程，由于请求需要的时长不一，在并发较大的时候会有请求排队、甚至还会出现线程阻塞的现象，这个配置可以改善这个问题。
# PermSize: 设置非堆内存初始值，默认是物理内存的1/64；
# MaxPermSize: 设置最大非堆内存的大小，默认是物理内存的1/4。
# DisableExplicitGC: 在程序代码中不允许有显示的调用”System.gc()”。
# UseParNewGC: 对年轻代采用多线程并行回收，这样收得快。
# MaxTenuringThreshold: 设置垃圾最大年龄。如果设置为0的话，则年轻代对象不经过Survivor区，直接进入年老代,根据本地的jprofiler监控后得到的一个理想的值，不能一概而论原搬照抄。
# UseConcMarkSweepGC: 即CMS gc，这一特性只有jdk1.5即后续版本才具有的功能，它使用的是gc估算触发和heap占用触发。
# CMSParallelRemarkEnabled: 在使用 UseParNewGC 的情况下，尽量减少 mark 的时间。
# UseCMSCompactAtFullCollection: 在使用 concurrent gc 的情况下，防止 memoryfragmention，对 live object 进行整理，使 memory 碎片减少。
# LargePageSizeInBytes: 指定 Java heap 的分页页面大小，内存页的大小不可设置过大， 会影响 Perm 的大小。
# UseFastAccessorMethods: 使用 get，set 方法转成本地代码，原始类型的快速优化。
# UseCMSInitiatingOccupancyOnly: 只有在 oldgeneration 在使用了初始化的比例后 concurrent collector 启动收集。
# UseBiasedLocking: -Djava.awt.headless=true这个参数一般我们都是放在最后使用的, 解决window下可以显示的图片在linux不能显示
export JAVA_OPTS="-server     
    -Xms1024M     
    -Xmx1024M     
    -Xss512k 
    -XX:+AggressiveOpts 
    -XX:+UseBiasedLocking 
    -XX:PermSize=128M 
    -XX:MaxPermSize=512M
    -XX:+DisableExplicitGC     
    -XX:+UseParNewGC
    -XX:MaxTenuringThreshold=15 
    -XX:+UseConcMarkSweepGC 
    -XX:+CMSParallelRemarkEnabled     
    -XX:+UseCMSCompactAtFullCollection 
    -XX:LargePageSizeInBytes=128m 
    -XX:+UseFastAccessorMethods 
    -XX:+UseCMSInitiatingOccupancyOnly 
    -Djava.awt.headless=true " 
