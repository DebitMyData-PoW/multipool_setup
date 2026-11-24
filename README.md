# multipool_setup

The DebitMyData pool installer's first stage: the checks, the user account the install runs
as, and the menu. It does nothing on its own: start from
[DebitMyData-PoW/Multi-Pool-Installer](https://github.com/DebitMyData-PoW/Multi-Pool-Installer).

| File | What it does |
| --- | --- |
| `start.sh` | The entry point (the `multipool` command runs it) |
| `preflight.sh` | Checks for Ubuntu 24.04 on x86_64 and enough memory; adds swap on a small server |
| `first_user.sh` | As root: makes the user account, copies root's SSH keys to it |
| `pre_setup.sh` | Finds the server's public IP addresses |
| `menu.sh` | The menu: the YiiMP single server only |
| `bootstrap_single.sh` | Downloads and starts [multipool_yiimp_single](https://github.com/DebitMyData-PoW/multipool_yiimp_single) |
| `bootstrap_coin.sh` | The coin daemon builder, not in the menu until it builds DebitMyData Core 1.3 (CMake) |
| `functions.sh` | Shared functions, copied to `/etc/functions.sh` |

Based on the installer by cryptopool.builders (Original-Tasty) and le2Ks, itself based on
[Mail-in-a-Box](https://github.com/mail-in-a-box/mailinabox).
