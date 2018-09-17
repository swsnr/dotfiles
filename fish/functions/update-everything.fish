# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

function update-everything -d "Update all my stuff"
    if string match --quiet 'darwin*' $OSTYPE
        echo -s (set_color -o) 'Updating homebrew' (set_color normal)
        brew upgrade
    end

    if command --search apt-get >/dev/null
        echo -s (set_color -o) 'Update APT packages' (set_color normal)
        sudo apt-get update
        sudo apt-get upgrade
    end

    echo -s (set_color -o) 'Update Rust packages' (set_color normal)
    cargo install-update --all

    if command --search tlmgr >/dev/null
        echo -s (set_color -o) 'Update all Texlive packages' (set_color normal)
        sudo tlmgr update --self --all
    end
end
