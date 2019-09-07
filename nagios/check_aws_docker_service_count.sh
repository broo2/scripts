#!/bin/bash
# This Nagios plugin runs check_nrpe functtionality against all members of a specificed AWS Autoscaling Group (ASG).
# It runs the check_docker_service command which must be present in nrpe.cfg on the remote hosts.  That in turn does docker container ls to
# look for the indicate service to be running within docker.
# To use it, pass the ASG Name in the -H parameter instead of the hostname.  Then pass a portion of the name of the service you want to check for
# -s and the minimum number of acceptable instances as the m parameter.
#
# Test this with
# check_aws_docker_service_count.sh -H  ENG1-cntrain-AppDockerTemlate-XLFGH4XPITAI-rAutoScalingGroupDockerMaster-15JAS9KNKHWM8  -s CNI_kong -m 3

AWS_OPTS="--profile nagios"

got_ok=0
got_warn=0
got_critical=0
got_unknown=0
crit_out=""
warn_out=""
ok_out=""
unkown_out=""

while getopts :H:s:m: o
do      case "$o" in
        H)      group="$OPTARG";;
        s)      service="$OPTARG";;
        m)      min="$OPTARG";;
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
        tmpstr=`/usr/local/nagios/libexec/check_nrpe -c check_docker_service_count -H $ip -a $service`
	if [ "$tmpstr" == "NRPE: Unable to read output" ]
	then
		echo "Service not found on master $ip"
		exit 2
	fi

	numerator=`echo $tmpstr | cut -d"/" -f1`
	denominator=`echo $tmpstr | cut -d"/" -f2`
	respstr="Service $service running $numerator instances, expected $min instances, per master $ip"
	if [ $numerator -lt $min ] 
	then
	 	respval=2
	else
		respval=0
	fi

	# we only need to do this on one master
	break
done

echo $respstr
exit $respval
