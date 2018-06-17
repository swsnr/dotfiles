# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

if begin
        status is-interactive
        and string match --quiet 'iTerm*' $TERM_PROGRAM
    end
    set iterm2_hostname (hostname -f)
    function update_iterm2_location --on-event fish_prompt
        # Tell item what directory, what host we're on, and that the prompt is
        # about to begin
        iterm2_command 'current_dir' (pwd)
        iterm2_command 'remote_host' $USER $iterm2_hostname
        iterm2_command 'prompt'
    end

    function update_iterm2_exit_status --on-event fish_postexec
        # Tell iterm2 the exit code of the last command
        iterm2_command 'command_finished' $status
    end

    update_iterm2_location
end
