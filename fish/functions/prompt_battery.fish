# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

function prompt_battery -d 'Battery information for prompt'
    if string match --quiet 'darwin*' $OSTYPE
        prompt_battery_macos
    end
end
