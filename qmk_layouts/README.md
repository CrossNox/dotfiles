# QMK setup
Run both as sudo and user

```bash
uvx tool install qmk
qmk setup
```

And run `qmk setup` first as non-sudo. This is to install the dependencies.


The `udev rules` located in `root/etc/udev/rules.d` should be managed through `stow`. Check the `fedora_setup.sh` script for that and reloading the rules.

Now you can run `qmk` as non-root.
