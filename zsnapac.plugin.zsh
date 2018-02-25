###
# John Ramsden
# johnramsden @ github
# Version 0.1.0
###

## Local variables and functions

source ${0:A:h}/zsnapac-settings.zsh

# Array of datasets to snapshot
local datasets=${ZFS_PAC_SNAP_DATASETS}

function zsnapac_help_output() {
  printf "%-25s | %-50s\n" "  ${1}" "${2}"
}

function zsnapac_usage() {
  echo "zsnapac usage"
  echo
  echo "-------------------------------------------------------------"
  echo "  zsnapac [subcommand]"
  echo
  echo "-------------------------------------------------------------"
  echo "Main command:"
  zsnapac_help_output "zsnapac" "Update system with pre/post ZFS snapshots"
  echo
  echo "-------------------------------------------------------------"
  echo "Sub commands:"
  zsnapac_help_output "update" "Update system with pre/post ZFS snapshots"
  zsnapac_help_output "install <packages>" "Install packages with pre/post ZFS snapshots"
  zsnapac_help_output "aur [packages]" "Run self defined aur command set in  'zsnapac-settings.zsh'"

  echo
  echo "-------------------------------------------------------------"
  echo "To set the ZFS snapshot datasets edit 'zsnapac-settings.zsh' setting 'datasets, "

  echo

  return 0;
}

# Helper function to iterate over snapshots
function iterate_snaps(){
  command="${1}"
  snap_name="${2}"

  for dataset in ${ZFS_PAC_SNAP_DATASETS[@]}; do

    if [ ${command} = "create" ]; then
      echo "Taking snapshot: ${dataset}@${snap_name}"
      sudo zfs snapshot "${dataset}@${snap_name}"
      snap_success=${?}
    elif [ ${command} = "destroy" ]; then
      echo "Destroying snapshot: ${dataset}@${snap_name}"
      sudo zfs destroy "${dataset}@${snap_name}"
      snap_success=${?}
    else
      echo "No such command ""'""${command}""'"
      return 2
    fi

    if [ ${snap_success} -ne 0 ]; then
      echo "Failed to ${command} snapshot ${dataset}@${snap_name}"
      return 1
    fi
  done

  return 0
}

# AUR update, run command defined in 'zsnapac-settings'
# ZFS Snapshot before command
# Update with pre and post snapshot
function zsnapac_aur(){
  snap_date="$(date +%Y-%m-%d-%H%M%S)"
  echo "Running aur command..."

  iterate_snaps "create" "pre-aur-${snap_date}"
  iterate_snaps_success=${?}
  if [ ${iterate_snaps_success} -ne 0 ]; then
    echo "Failed to iterate over datasets during pre-aur"
    return 1
  fi

  echo "Starting aur..."
  ZFS_AUR_UPDATE ${@:2}
  update_success=${?}

  if [ ${update_success} -ne 0 ]; then
    echo "Failed to run aur command."
    return 2
  fi

  iterate_snaps "create" "post-aur-${snap_date}"
  iterate_snaps_success=${?}
  if [ ${iterate_snaps_success} -ne 0 ]; then
    echo "Failed to iterate over datasets during post-aur"
    return 3
  fi

  return 0
}

# ZFS Snapshot before command
# Update with pre and post snapshot
function zsnapac_update(){
  snap_date="$(date +%Y-%m-%d-%H%M%S)"
  echo "Updating system..."

  iterate_snaps "create" "pre-update-${snap_date}"
  iterate_snaps_success=${?}
  if [ ${iterate_snaps_success} -ne 0 ]; then
    echo "Failed to iterate over datasets during pre-update"
    return 1
  fi

  echo "Starting update..."
  sudo pacman -Syu
  update_success=${?}
  if [ ${update_success} -ne 0 ]; then
    echo "Failed to run aur update with ""'""pacman -Syu""'"
    return 2
  fi

  iterate_snaps "create" "post-update-${snap_date}"
  iterate_snaps_success=${?}
  if [ ${iterate_snaps_success} -ne 0 ]; then
    echo "Failed to iterate over datasets during post-update"
    return 3
  fi

  return 0
}

function zsnapac_install(){
  packages=""
  snap_date="$(date +%Y-%m-%d-%H%M%S)"
  for var in $@; do
      packages="${packages}-${var}";
  done
  echo "Pre-install..."

  iterate_snaps "create" "pre-install${packages}-${snap_date}"
  iterate_snaps_success=${?}
  if [ ${iterate_snaps_success} -ne 0 ]; then
    echo "Failed to iterate over datasets during pre-install"
    return 1
  fi

  echo
  echo "Installing packages: ${@:2}..."
  sudo pacman -S ${@:2}
  install_success=${?}

  echo

  if [ ${install_success} -ne 0 ]; then
    echo "Failed to run install with ""'""pacman -S ${@}""'"
    return 2
  fi

  echo "Post-install..."

  iterate_snaps "create" "post-install${packages}-${snap_date}"
  iterate_snaps_success=${?}
  if [ ${iterate_snaps_success} -ne 0 ]; then
    echo "Failed to iterate over datasets during post-install"
    return 3
  fi

  return 0
}

function zsnapac() {
  command="${1:-upgrade}"

  case ${command} in
    update )
      zsnapac_update
      ;;
    install )
      zsnapac_install ${@:1}
      ;;
    aur )
      zsnapac_aur ${@:1}
      ;;
    * )
      zsnapac_usage
      ;;
  esac
}
