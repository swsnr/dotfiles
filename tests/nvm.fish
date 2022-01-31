@test "nvm install latest major.minor.patch" (
  nvm install latest >/dev/null 2>&1
  nvm current
) = (nvm list-remote | string match --regex -- "v\d+\.\d+\.\d+")[-1]

@test "nvm install latest minor.patch" (
  nvm install 5 >/dev/null 2>&1
  nvm current
) = v5.12.0

@test "nvm install latest patch" (
  nvm install v5.11 >/dev/null 2>&1
  nvm current
) = v5.11.1