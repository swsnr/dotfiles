# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

function iterm2_preexec -e fish_preexec -d 'Preexec function for iterm2'
    # Tell iterm2 that the command is running now
    iterm2_command 'command_executed'
end
