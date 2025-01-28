# Backups

I've never been very good about backups, but here's my attempt using [restic](https://restic.net/) and [resticprofile](https://creativeprojects.github.io/resticprofile/index.html) backing up to a [Backblaze B2](https://www.backblaze.com/cloud-storage) bucket. By only backing up data, it's pretty cheap: somewhere between a few cents and free.

Similar things are grouped together and tagged (i.e. the whole media stack is tagged `media`), and scheduled based on how frequently they're updated. It's pointless to back up things every day that change at most once a month.

## Setting Up

```sh
$ mkdir /etc/resticprofile
$ cd /etc/resticprofile
$ curl -O https://raw.githubusercontent.com/Benricheson101/lab/.../profiles.yaml
$ sops decrypt -i profiles.yaml
$ curl -O https://raw.githubusercontent.com/Benricheson101/lab/.../excludes.txt
$ vim password.txt
$ resticprofile schedule --all
```
