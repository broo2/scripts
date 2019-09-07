#!/bin/bash

RSYNC_OPTS=(--bwlimit=250000 -r -a)
EXCLUDE_LIST='--exclude="*.log"'

function show_help () {
cat << EOF
Options:
-u Username
-k SSH Key
-v Verbose
-s Remote server
-p Remote path to sync
-l log file

path_to sync|ALL_POOLS sync one path or all volumes from all pools

Usage sync.sh -l /path/to/log_file -v -u user -k /path/to/ssh_key -s remote_server_hostname -p /path/on/remote/host /path/to/sync
EOF
}

function array_contains () {
local seeking=$1; shift
local in=1
for element; do
if [[ $element == $seeking ]]; then
in=0
break
fi
done
return $in
}

while getopts "h?vl:k:s:u:" opt; do
case "$

{opt}
" in
h|?)
show_help
exit 0
;;
u)
username=$

{OPTARG}
;;
v)
verbose=1
RSYNC_OPTS+=(-v --progress)
;;
s)
remote_server=${OPTARG}
;;
p)
remote_path=$

{OPTARG}
;;
l)
log_path=${OPTARG}
;;
k)
ssh_key=$

{OPTARG}
;;
esac
done

shift $((OPTIND-1))

ssh_cmd="ssh -o StrictHostKeyChecking=no -i $

{ssh_key}
-l $

{username}"
remote="${username}
@$

{remote_server}:${remote_path}"
if array_contains ALL_POOLS "${@}"; then
IFS=$'\n'
pools=($(zpool list -H | awk '{print $1}' | awk '{for(i=1;i<=NF;i++) print $i;}'))
for filesystem in `zfs list -H -t filesystem | awk '{print $1}'`; do
if array_contains ${filesystem} "${pools[@]}"; then
# skip pool
continue
else
mountpoint=`zfs list -H ${filesystem} | awk '{print $5}'`
rsync --log-file="${log_path}" ${EXCLUDE_LIST} ${RSYNC_OPTS[@]} -e "${ssh_cmd}" "${mountpoint}" ${username}@${remote_server}
:"$

{remote_path}" &
fi
done
else
for path in $@; do
if [[ -d ${path} ]]; then
rsync --log-file="${log_path}" ${EXCLUDE_LIST} ${RSYNC_OPTS[@]} -e "${ssh_cmd}" "${path}" ${username}@${remote_server}:"${remote_path}
" &
else
echo "No such directory $path"
fi
done
fi