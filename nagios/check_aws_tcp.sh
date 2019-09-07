#!/bin/bash
# This Nagios plugin runs check_tcp functtionality against all members of a specificed AWS Autoscaling Group (ASG).
# To use it, pass the ASG Name in the -H parameter instead of the hostname.  Then pass any other parameters you
# normally would for check_http and they will be passed through.
#
# Test this with
# check_aws_tcp.sh -H PRD1-cntrain-AppApplicationTemlate-1T7I12MX8OF0T-rAutoScalingGroupJob-17SMIAZUEZGW6 -p 77

AWS_OPTS="--profile nagios"

outstring=""
got_ok=0
got_warn=0
got_critical=0
got_unknown=0

while getopts :H: o
do      case "$o" in
        H)      group="$OPTARG";;
        esac
done

instance_list=$(aws autoscaling describe-auto-scaling-groups ${AWS_OPTS} --auto-scaling-group-names $group --output text --query 'AutoScalingGroups[].Instances[?LifecycleState==`InService`].InstanceId')

if [ "x$instance_list" = "x" ]
then
        echo "No members found in autoscaling group"
        exit 3
fi

for instance in $instance_list
do
        as_state=$(aws autoscaling describe-auto-scaling-instances ${AWS_OPTS} --instance-ids $instance --query "AutoScalingInstances[?InstanceId == \`$instance\`].LifecycleState | [0]" --output text)
        if [ "$as_state" != "InService" ] ; then continue ; fi

        ip=`aws ec2 describe-instances ${AWS_OPTS} --instance-id $instance --output text --query 'Reservations[].Instances[].PrivateIpAddress'`
        passthru_args=`echo $@ | sed "s/$group/$ip/"`
        respstr=`/usr/local/nagios/libexec/check_tcp $passthru_args`
        respval=$?
        respstr_trim=`echo $respstr | awk -F"|" '{print $1}'`
        if [ "x$outstring" = "x" ]
        then
                outstring=`echo -e "$instance ($ip): $respstr_trim"`
        else
                outstring=`echo -e "$outstring\n$instance ($ip): $respstr_trim"`
        fi

        case $respval in
        0) got_ok=1 ;;
        1) got_warn=1 ;;
        2) got_critical=1 ;;
        3) got_unknown=1 ;;
        *) got_unknown=1 ;;
        esac
done

echo -e "$outstring"

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

