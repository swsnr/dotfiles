function __wezterm_preprompt --on-event fish_prompt
    printf "\e]133;A;cl=m;aid=%s\a" $fish_pid
end

function __wezterm_preexec --on-event fish_preexec
    printf "\e]133;C\a"
end

function __wezterm_postexec --on-event fish_postexec
    printf "\e]133;D;%s;aid=%s\a" $status $fish_pid
end

function wezterm_cancel --on-event fish_cancel
    # Last input was cancelled, so we don't report any exit code
    printf "\e]133;D;aid=%s\a" $fish_pid
    __wezterm_preprompt
end
