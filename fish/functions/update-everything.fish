# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

function update-everything -d "Update all my stuff"
    pushd ~/GitHub/playbooks
    echo -s (set_color -o) 'Updating playbooks' (set_color normal)
    git pull --rebase --autostash
    echo -s (set_color -o) 'Updating system via ansible playbooks' (set_color normal)
    ansible-playbook -t update -l (hostname -s) $argv site.yml
    popd
end
