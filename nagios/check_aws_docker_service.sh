#!/bin/bash
# This Nagios plugin runs check_nrpe functtionality against all members of a specificed AWS Autoscaling Group (ASG).
# It runs the check_docker_service command which must be present in nrpe.cfg on the remote hosts.  That in turn does docker container ls to
# look for the indicate service to be running within docker.
# To use it, pass the ASG Name in the -H parameter instead of the hostname.  Then pass a portion of the name of the service you want to check for
# as BOTH the -s and -a parameters.  (This is odd but necessary because of how this is built.)
#
# Test this with
# check_aws_nrpe.sh -H  ENG1-cntrain-AppDockerTemlate-XLFGH4XPITAI-rAutoScalingGroupDockerWorker-17KGP77HMTHHM  -c CNG_kong -s CNG_kong

AWS_OPTS="--profile nagios"

got_ok=0
got_warn=0
got_critical=0
got_unknown=0
crit_out=""
warn_out=""
ok_out=""
unkown_out=""

while getopts :H:s: o
do      case "$o" in
        H)      group="$OPTARG";;
	s)	service="$OPTARG";;
        esac
done

instance_list=`aws autoscaling describe-auto-scaling-groups ${AWS_OPTS} --auto-scaling-group-names $group --output text --query 'AutoScalingGroups[].Instances[].InstanceId'`

if [ "x$instance_list" = "x" ]
then
        echo "No members found in autoscaling group"
        exit 3
fi

for instance in $instance_list
do
        ip=`aws ec2 describe-instances ${AWS_OPTS} --instance-id $instance --output text --query 'Reservations[].Instances[].PrivateIpAddress'`
        passthru_args=`echo $@ | sed "s/$group/$ip/"`
	# below we pass the service parameter to nrpe to limit the size of the list, but we also grep for it when it comes back here.
	# we  do that because the "docker container ls" command we run will always have a success status even if the service isn't running.
	# the extra grep is an easy way to see if the service really was listed in the output we got back from nrpe.
        respstr=`/usr/local/nagios/libexec/check_nrpe -c check_docker_service $passthru_args -a $service | grep $service`
        respval=$?
	respval=`expr $respval \* 2`
	respstr_trim=`echo $respstr | awk -F"|" '{print $1}'`

        case $respval in
        0) got_ok=1
           if [ "x$ok_out" = "x" ]; then ok_out=`echo -e "$instance ($ip): $respstr_trim"`; else ok_out=`echo -e "$ok_out\n$instance ($ip): $respstr_trim"`; fi
           ;;
        1) got_warn=1
           if [ "x$warn_out" = "x" ]; then warn_out=`echo -e "$instance ($ip): $respstr_trim"`; else warn_out=`echo -e "$warn_out\n$instance ($ip): $respstr_trim"`; fi
           ;;
        2) got_critical=1
           if [ "x$crit_out" = "x" ]; then crit_out=`echo -e "$instance ($ip): $respstr_trim"`; else crit_out=`echo -e "$crit_out\n$instance ($ip): $respstr_trim"`; fi
           ;;
        *) got_unknown=1
           if [ "x$unknown_out" = "x" ]; then unknown_out=`echo -e "$instance ($ip): $respstr_trim"`; else unknown_out=`echo -e "$unknown_out\n$instance ($ip): $respstr_trim"`; fi
           ;;
        esac
done

if [ "x$crit_out" != "x" ]; then echo -e "$crit_out"; fi
if [ "x$warn_out" != "x" ]; then echo -e "$warn_out"; fi
if [ "x$unknown_out" != "x" ]; then echo -e "$unkown_out"; fi
if [ "x$ok_out" != "x" ]; then echo -e "$ok_out"; fi

if [ $got_critical = 1 ]
then
        exit 2
fi

if [ $got_warn = 1 ]
then
        exit 1
fi

if [ $got_unknown = 1 ]
then
        exit 3
fi

if [ $got_ok = 1 ]
then
        exit 0
fi

exit 3
