# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

function java-gc-details -w java -d 'Print GC details of the JVM'
    java -XX:+PrintCommandLineFlags -XX:+PrintGCDetails $argv -version
end
