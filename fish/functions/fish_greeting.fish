# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

function fish_greeting -d 'My cow says things to you!'
    if not command --quiet --search cowsay
        echo 'I am silent. Install cowsay!'
        return 1
    end
    if not command --quiet --search fortune
        cowsay -y 'I have nothing to say. Install fortune!'
        echo
        return 1
    end

    # -s gives me just a short story; don't want to read a novel whenever
    # I start a shell
    fortune -s | cowsay -f kitty -W (math $COLUMNS - 10)
    echo

    # At work, automatically authenticate against the firewall with identity
    # from keychain
    if hostname | string match -q 'GFMB*'
        set -l authenticate (command -s gf-fw-authenticate)
        if test $status -eq 0
            eval $authenticate
            echo
        else
            echo 'gf-fw-authenticate not found, cannot authenticate on firewall'
        end
    end
end
