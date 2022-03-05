function wezterm_preprompt --on-event fish_prompt
    printf "\033]133;A;cl=m;aid=%s\007" $fish_pid
    printf "\033]133;P;k=i\007"
end

function wezterm_preexec --on-event fish_preexec
    printf "\033]133;C\007"
end

function wezterm_postexec --on-event fish_postexec
    printf "\033]133;D;%s;aid=%s\007" $status $fish_pid
end

function wezterm_cancel --on-event fish_cancel
    # Last input was cancelled, so we don't report any exit code
    printf "\033]133;D;aid=%s\007" $fish_pid
    # Tell wezterm that we're starting a new prompt again
    printf "\033]133;A;cl=m;aid=%s\007" $fish_pid
    printf "\033]133;P;k=i\007"
end
