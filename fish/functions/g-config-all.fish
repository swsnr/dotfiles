# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

function g-config-all -d 'Run git config option in all sub-directories'
    for gitdir in **/.git
        set -l workdir (dirname $gitdir)
        echo "$workdir git config $argv"
        git -C $workdir config $argv
    end
end
