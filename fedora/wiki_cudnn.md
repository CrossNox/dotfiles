# Fedora install
Read carefully [this guide](https://www.reddit.com/r/Dell/comments/9724vh/xps_9560_fedora_28_guide_for_power_saving_and_no/) before proceeding.

In this repo in `fedora/etc_default_grub` you have the needed grub cfg. There's a comment at the top on how to update the grub config.

To enable the nvidia driver follow [these commands](https://www.reddit.com/r/Fedora/comments/7duqbs/psa_how_i_got_the_negativo17_nvidia_drivers/) which uses [Negativo 17's repo](https://negativo17.org/nvidia-driver/)

In case you are wondering again about [nomodeset, quiet and splash](just a reminder https://askubuntu.com/questions/716957/what-do-the-nomodeset-quiet-and-splash-kernel-parameters-mean) kernel parameters.

Algo del estilo `sudo dnf install kernel-devel dkms dkms-nvidia nvidia-driver nvidia-settings  nvidia-driver-libs.i686 nvidia-driver-cuda cuda-devel` seguido de `sudo dkms autoinstall` deberia andar.

Si rompiste todo, podes hacer un muy violento `sudo dnf remove *nvidia*` y hacerlo de nuevo.

Fijate que `nvidia-smi` no pinche.

# cudNN
Using the `negativo17` repo, you might get this error after updates/upgrades, not covered by the fixes on `wiki_cudnn`.
```
W tensorflow/stream_executor/platform/default/dso_loader.cc:59] Could not load dynamic library 'libcudart.so.10.1'; dlerror: libcudart.so.10.1: cannot open shared object file: No such file or directory
```

## Fix
Check `upgrades.md`

