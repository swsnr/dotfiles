# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

# See https://iterm2.com/documentation-escape-codes.html
function ftcs_escape_code -d 'Send an FTCS escape code'
    printf "\033]133;%s\007" $argv[1]
end
