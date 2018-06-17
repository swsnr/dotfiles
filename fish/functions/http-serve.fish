# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

function http-serve -d 'Serve the current directory over HTTP'
    python -m SimpleHTTPServer $argv
end
