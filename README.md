# zsnapac

oh-my-zsh plugin for taking ZFS pre/post upgrade snapshots on Arch Linux.

## Setup

Requires ZFS and oh-my-zsh.

Clone the plugin in your oh-my-zsh plugin directory.

```shell
cd ${ZSH_CUSTOM}/plugins
git clone git@github.com:johnramsden/zsh-zsnapac.git zsnapac
```

Now add the plugin to your zshrc active plugins, it should be added as 'zsnapac'.

```shell
plugins=(zsnapac)
```

## Options

To set the options, edit the `zsnapac-settings.zsh` configfile

* ```ZFS_PAC_SNAP_DATASETS=("zpool/ROOT/default")```           - Dataset(s) to snapshot.
* ```ZFS_AUR_UPDATE```  - To use an aur updater, override or set the `ZFS_AUR_UPDATE` function

## Usage

The ```zsnapac``` command is used to manage the updates and installs

The following commands exist:

* ```zsnapac | zsnapac update```  - Update system with pre/post ZFS snapshots
* ```zsnapac install <packages>``` - Install packages with pre/post ZFS snapshots
* ```zsnapac aur [packages]``` - Run self defined aur command set in  'zsnapac-settings.zsh'
