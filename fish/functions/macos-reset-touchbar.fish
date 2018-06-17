# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

# See <https://github.com/rgcr/m-cli/pull/122>
function macos-reset-touchbar -d 'Reset macOS touchbar'
    pkill "Touch Bar agent"
    killall ControlStrip
end
