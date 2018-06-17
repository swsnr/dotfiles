# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

function mkc --description 'Create directory and change into it'
    if [ (count $argv) -gt 0 ]
        set -l directory $argv[1]
        mkdir -p $directory
        cd $directory
    else
        echo 'Missing directory name'
        return 1
    end
end
