# QMK setup
Run both as sudo and user

```bash
pipx install qmk
qmk setup
```

And run `qmk setup` first as non-sudo. This is to install the dependencies.


Install the `udev rules` (in `/etc/udev/rules.d`) and run:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Now you can run `qmk` as non-root.
