# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

function get -d 'Download from a remote URL'
    if command --search 'curl' >/dev/null
        curl --continue-at - --location --progress-bar --remote-name --remote-time $argv
    else if command --search 'wget' >/dev/null
        wget --continue --progress=bar --timestamping $argv
    else
        echo 'Don\'t know how to download 😞'
        return 1
    end
end
