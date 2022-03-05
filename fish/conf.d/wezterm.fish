function wezterm_preprompt --on-event fish_prompt
    printf "\033]133;A;cl=m;aid=%s\007" $fish_pid
    printf "\033]133;P;k=i\007"
end

function wezterm_preexec --on-event fish_preexec
    printf "\033]133;C\007"
end

