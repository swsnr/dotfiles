# Copyright (C) 2017  Sebastian Wiesner <sebastian@swsnr.de>
# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

function safari-url -d 'Get current URL from Safari'
    osascript -e 'tell application "Safari" to get URL of current tab of front window'
end
