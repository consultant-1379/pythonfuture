#!/bin/bash

log() {
  msg=$2
  dev_log=/dev/log
  if [[ -S "$dev_log" ]]; then
    case $1 in
    info)
      logger -s -t pyu_install -p 'user.notice' "$msg"
    ;;
    error)
      logger -s -t "python-future" -p 'user.error' "$msg"
    ;;
    esac
  else
    case $1 in
    info)
      echo "$(date +'%b  %u %T') python-future_install [INFO]" "$msg"
    ;;
    error)
      echo "$(date +'%b  %u %T') python-future_install [ERROR]" "$msg"
    ;;
    esac
  fi
}

log info "Running EXTRpythonfuture_CXP9043068 RPM Post-Install"

function get_site_packages_location() {
  python_version=$1
  SITE=`/usr/bin/python${python_version} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"`
  retcode=$?
  if [ ${retcode} -ne 0 ]; then
    log error "Failed to get python site-packages directory for python${python_version}."
  fi
  echo ${SITE}
}

if grep "Red Hat Enterprise Linux Server release 7." /etc/redhat-release > /dev/null 2>&1; then
  site_packages=$(get_site_packages_location 2)
else
  site_packages=$(get_site_packages_location 3)
fi

common_site_packages="/usr/lib/python-common/python-future/site-packages"
for file_path in ${common_site_packages}/*
do
  log info "Creating symbolic link from ${file_path} to ${site_packages}"
  ln -s -f "${file_path}" "${site_packages}"
  if [ $? -ne 0 ]; then
    log error "Failed to created symbolic link from ${file_path} to ${site_packages}"
    exit 1
  fi
done

log info "Symbolic links successfully created from ${common_site_packages} to ${site_packages}"

log info "Finished EXTRpythonfuture_CXP9043068 RPM Post-Install"
