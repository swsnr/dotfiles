# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

function setup-system -d "Setup this system from playbooks"
    pushd ~/GitHub/playbooks
    echo -s (set_color -o) 'Updating playbooks' (set_color normal)
    git pull --rebase --autostash
    echo -s (set_color -o) 'Setting up system via ansible playbooks' (set_color normal)
    ansible-playbook -l (hostname -s) $argv site.yml
    popd
end
