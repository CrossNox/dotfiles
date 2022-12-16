# Checklist of things that probably got messed up
- Jupyterlab
- Plex
- qBittorrent

# Checklist of things that most definitely got messed up
## Tensorflow
Run `python -c "import tensorflow"` on a python environment with `tensorflow-gpu` installed.

Using the `negativo17` repo, you might get this error after updates/upgrades, not covered by the fixes on `wiki_cudnn`:

```
W tensorflow/stream_executor/platform/default/dso_loader.cc:59] Could not load dynamic library 'libcudart.so.10.1'; dlerror: libcudart.so.10.1: cannot open shared object file: No such file or directory
```

## Fix
```
pip install -U tensorflow-gpu keras
ls -lrth /usr/lib64/libcudart**
```

See what you got and `ln -s /usr/lib64/libcudart.so /usr/lib64/libcudart.so.10.1`


## Postgres
```
# systemctl status postgresql.service
```

If might have died on update, and it will tell you to run `sudo postgresql-setup --upgrade`. If `postgis` doesn't let you update, you can try installing `sudo dnf install postgis-upgrade`. You can start/kill old/new versions of postgres with `/usr/lib64/pgsql/postgresql-11/bin/pg_ctl -D /var/lib/pgsql/data/ stop` or something like that. Create a dump of the conflicting db, drop it and run the upgrade script again.

## pipx
```bash
rm -rf ~/.local/pipx
pipx reinstall-all
```

Or, just reinstall from script instructions.
