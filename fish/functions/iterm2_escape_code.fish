# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

# See https://iterm2.com/documentation-escape-codes.html
function iterm2_escape_code -d 'Send an escape code to iterm2'
    printf "\033]1337;%s\007" $argv[1]
end
