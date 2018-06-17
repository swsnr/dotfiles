# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

# Personal prompt of Sebastian Wiesner <sebastian@swsnr.de>
#
# Features iTerm integration, command exit status, sudo and SSH support, working
# directory, virtualenv, battery information and git status.

function fish_prompt -d 'My personal prompt'
    # Indicate exit code of last command
    if test $status -eq 0
        echo -sn (set_color green) '✔'
    else
        echo -sn (set_color -o red) '!'
    end
    echo -sn (set_color normal)
    if set -q SUDO_USER
        # Show the target user name when in a sudo shell
        echo -sn ' ' (set_color -o red) $USER (set_color normal)
    else if set -q SSH_CONNECTION
        # When connected via SSH show the login user name
        echo -sn ' ' (set_color magenta) $USER (set_color normal)
    end
    if set -q SSH_CONNECTION
        # When connected via SSH show the target system
        echo -sn '@' (set_color magenta) (prompt_hostname) (set_color normal)
    end
    # Working directory
    echo -sn ' ' (set_color cyan) (prompt_pwd) (set_color normal)
    # Python virtualenv if any
    if set -q VIRTUAL_ENV
        echo -sn ' (' (set_color -i cyan) (basename $VIRTUAL_ENV) (set_color normal) ')'
    end
    # Prompt separator
    echo -sn (set_color green) ' ❯ ' (set_color normal)
    # Tell iterm that the command input starts now
    iterm2_command 'command_start'
end
