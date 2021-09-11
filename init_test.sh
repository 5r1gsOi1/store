#!/bin/bash

MY_USER_NAME=`whoami`
IS_INSIDE_VM=false

perform_admin_work()
{
  ################################################################################
  #
  #  Check if running inside VM, only Oracle VirtualBox is supported for now
  #
  ################################################################################

  check_if_inside_vm()
  {
    chassis="$(hostnamectl status | grep "Chassis:"  | awk '/Chassis:/{print $NF}')"
    hypervisor="$(dmesg | egrep -o "Hypervisor detected:.*" | awk '/Hypervisor detected:/{print $NF}')"
    VM_MANUFACTURER="$(systemd-detect-virt)"
    if [ -z "$hypervisor" ] || [ "$chassis" != "vm" ] || [ "$VM_MANUFACTURER" != "none" ]
    then
      IS_INSIDE_VM=true
      return 1
    else
      return 0
    fi
  }

  ################################################################################
  #
  #  Adding user to groups
  #
  ################################################################################

  echo "USER = $MY_USER_NAME"
  sudo usermod -aG sudo "$MY_USER_NAME"
  check_if_inside_vm
  if [ ! -z "$IS_INSIDE_VM" ]; then
    echo "We are inside vm, manufacturer is \"$VM_MANUFACTURER\""
    if [ "$VM_MANUFACTURER" = "oracle" ]; then
      echo " ... assuming VirtualBox"
      sudo usermod -aG vboxsf "$MY_USER_NAME"
    fi
  fi

  ################################################################################
  #
  #  Installing software
  #
  ################################################################################

  export DEBIAN_FRONTEND=noninteractive
  apt update 
  apt install -yq aptitude update-alternatives

  ################################################################################
  #
  #  Setting up multiple sources for aptitude
  #  https://serverfault.com/questions/22414/how-can-i-run-debian-stable-but-install-some-packages-from-testing
  #
  ################################################################################

  MIRROR_ADDRESS="http://mirror.corbina.net/debian/"
  APT_DIR="/etc/apt"

  PREF_DIR="${APT_DIR}/preferences.d"
  SOURCES_DIR="${APT_DIR}/sources.list.d"

  mkdir ${PREF_DIR}

  echo -e "# 500 <= P < 990: causes a version to be installed unless there is a\n# version available belonging to the target release or the installed\n# version is more recent\n\nPackage: *\nPin: release a=stable\nPin-Priority: 900" > ${PREF_DIR}/stable.pref

  echo -e "# 100 <= P < 500: causes a version to be installed unless there is a\n# version available belonging to some other distribution or the installed\n# version is more recent\n\nPackage: *\nPin: release a=testing\nPin-Priority: 400" > ${PREF_DIR}/testing.pref

  echo -e "# 0 < P < 100: causes a version to be installed only if there is no\n# installed version of the package\n\nPackage: *\nPin: release a=unstable\nPin-Priority: 50" > ${PREF_DIR}/unstable.pref

  echo -e "# 0 < P < 100: causes a version to be installed only if there is no\n# installed version of the package\n\nPackage: *\nPin: release a=experimental\nPin-Priority: 1" > ${PREF_DIR}/experimental.pref

  create_sources_for_stable()
  {
    RESULT=""
    RESULT="${RESULT}deb ${MIRROR_ADDRESS} stable main\n"
    RESULT="${RESULT}deb-src ${MIRROR_ADDRESS} stable main\n\n"

    RESULT="${RESULT}deb http://security.debian.org/debian-security stable/updates main\n"
    RESULT="${RESULT}deb-src http://security.debian.org/debian-security stable/updates main\n\n"

    RESULT="${RESULT}deb ${MIRROR_ADDRESS} stable-updates main\n"
    RESULT="${RESULT}deb-src ${MIRROR_ADDRESS} stable-updates main\n"
    SOURCES=${RESULT}
  }

  create_sources_for_testing()
  {
    RESULT=""
    RESULT="${RESULT}deb ${MIRROR_ADDRESS} testing main\n"
    RESULT="${RESULT}deb-src ${MIRROR_ADDRESS} testing main\n\n"

    RESULT="${RESULT}deb http://security.debian.org/debian-security testing-security/updates main\n"
    RESULT="${RESULT}deb-src http://security.debian.org/debian-security testing-security/updates main\n\n"

    RESULT="${RESULT}deb ${MIRROR_ADDRESS} testing-updates main\n"
    RESULT="${RESULT}deb-src ${MIRROR_ADDRESS} testing-updates main\n"
    SOURCES=${RESULT}
  }

  create_sources_for_unstable()
  {
    RESULT=""
    RESULT="${RESULT}deb ${MIRROR_ADDRESS} unstable main\n"
    RESULT="${RESULT}deb-src ${MIRROR_ADDRESS} unstable main\n\n"
    SOURCES=${RESULT}
  }

  create_sources_for_experimental()
  {
    RESULT=""
    RESULT="${RESULT}deb ${MIRROR_ADDRESS} experimental main\n"
    RESULT="${RESULT}deb-src ${MIRROR_ADDRESS} experimental main\n\n"
    SOURCES=${RESULT}
  }

  mkdir ${SOURCES_DIR}

  create_sources_for_stable
  echo -e ${SOURCES} > ${SOURCES_DIR}/stable.list
  create_sources_for_testing
  echo -e ${SOURCES} > ${SOURCES_DIR}/testing.list
  create_sources_for_unstable
  echo -e ${SOURCES} > ${SOURCES_DIR}/unstable.list
  create_sources_for_experimental
  echo -e ${SOURCES} > ${SOURCES_DIR}/experimental.list

  mv "${APT_DIR}/sources.list" "${APT_DIR}/sources.list.orig"

  aptitude update
  aptitude -yq upgrade

  ################################################################################
  #
  #  Installing software
  #
  ################################################################################

  aptitude install -yq mc vim gedit meld terminator qterminal ranger fakeroot
  aptitude install -yq build-essential gcc g++ make cmake git valgrind gdb linux-headers-$(uname -r)  
  aptitude install -yq bison flex
  aptitude install -yq llvm clang clang-format clang-tidy
  aptitude install -yq gdbserver gnuplot zlibc bzip2 icu-devtools lzma zstd
  aptitude install -yq chromium
  aptitude install -yq qtcreator cppcheck graphviz

  ################################################################################
  #
  #  Keyboard layouts
  #
  ################################################################################




  ################################################################################
  #
  #  Menu and appearance
  #
  ################################################################################


  ################################################################################
  #
  #  disable screensaver
  #
  ################################################################################


  ################################################################################
  #
  #  qtcreator settings
  #
  ################################################################################



  ################################################################################
  #
  #  terminal settings
  #
  ################################################################################

  


}

echo -e "\nRunning as root"
su -c bash -c "$(declare -f perform_admin_work); declare MY_USER_NAME=\"$MY_USER_NAME\"; perform_admin_work"

if [ $? -ne 0 ]; then
  echo -e "Aborted\n"
  exit
fi


################################################################################
#
#  prepare working dirs
#
################################################################################

mkdir ~/git

# create test cpp project dir


################################################################################
#
#  generate ssh key
#
################################################################################


################################################################################
#
#  qtcreator settings
#
################################################################################



