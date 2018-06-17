# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

function java-final-flags -w java -d 'Print final flags for the JVM'
    java -XX:+PrintFlagsFinal $argv -version
end
