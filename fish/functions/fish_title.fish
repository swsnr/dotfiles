# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

function fish_title -d 'Window title for fish'
    if test (count $argv) -gt 0
        echo $argv[1] ' $ ' (prompt_pwd)
    else
        prompt_pwd
    end
end
