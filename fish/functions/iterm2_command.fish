# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

# See https://iterm2.com/documentation-escape-codes.html for escape codes
function iterm2_command -d 'Run an escape code command for iterm2'
    set -l command $argv[1]
    set -l args
    if [ (count $argv) -gt 1 ]
        set args $argv[2..-1]
    else
        set args []
    end
    switch $command
        case 'prompt'
            ftcs_escape_code 'A'
        case 'command_start'
            ftcs_escape_code 'B'
        case 'command_executed'
            ftcs_escape_code 'C'
        case 'command_finished'
            if [ (count $args) -eq 0 ]
                ftcs_escape_code 'D'
            else
                ftcs_escape_code (printf 'D;%s' $args)
            end
        case 'current_dir'
            iterm2_escape_code (printf 'CurrentDir=%s' $args)
        case 'remote_host'
            iterm2_escape_code (printf 'RemoteHost=%s@%s' $args)
        case '*'
            echo 'Unknown command', $command
            return 1
    end
end
