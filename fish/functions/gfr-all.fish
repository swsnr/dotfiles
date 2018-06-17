# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

function gfr-all -d 'git pull --rebase all sub-directories'
    for gitdir in **/.git
        set -l workdir (dirname $gitdir)
        echo $workdir
        git -C $workdir pull --rebase --autostash
    end
end
