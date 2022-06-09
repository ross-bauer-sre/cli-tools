# add-keys
add-keys is a shell helper that ensures your daily use keys are always available in your key agent. It will check your key agent against your ssh key files (minus any line separated filepaths in your ~/.add-keys/blacklist file) and re-add your keys if the two don't match.

N.B - this check is currently done in a very noddy way using the _number_ of keys, so this script won't work if you manually added keys separately to your agent. It is designed to be a quick and dirty helper script.

Run `./install.sh` and re-source your shell config, and you're cooking.

TODO:
   
    - Check key hashes to make sure the correct keys are loaded in the agent when making the comparison.