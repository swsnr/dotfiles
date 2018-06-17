# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

function update-everything -d "Update all my stuff"
    echo -s (set_color -o) 'Updating homebrew' (set_color normal)
    if string match --quiet 'darwin*' $OSTYPE
        brew upgrade
    end
    echo -s (set_color -o) 'Update Rust packages' (set_color normal)
    cargo install-update --all
    echo -s (set_color -o) 'Update all Texlive packages' (set_color normal)
    sudo tlmgr update --self --all
end
