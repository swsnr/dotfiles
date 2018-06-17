# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

function demo-prompt -d 'Switch to a simple prompt for demo purposes'
    # Disable the right-hand side prompt and the separate mode prompt
    function fish_right_prompt
    end

    function fish_mode_prompt
    end

    function fish_prompt -d 'Simple demo prompt'
        switch $fish_bind_mode
            case insert
                set_color --background green --bold white
            case replace-one
                set_color --background green --bold white

            case visual
                set_color --background magenta white
            case default
                set_color --background red white
        end
        echo -n '$'
        set_color normal
        echo -n ' '
    end
end
