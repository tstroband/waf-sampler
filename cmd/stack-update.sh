#!/usr/bin/env bash

function usage() {
    echo "usage:"
    echo "   stack-update -stack=<stack-name> -profile=<profile>"
    echo "                [-exec=<exec>] [-<param-name>=<param-value>]*"
    echo "parameters:"
    echo "   -stack           The name of the Cloud Formation stack"
    echo "                    template"
    echo "   -profile         The name of AWS profile to use"
    echo "                    Default: 'default'"
    echo "   -exec            Execute the change set immediately. Set to 'false' "
    echo "                    to review first and execute manually."
    echo "                    Valid values: 'true' or 'false'."
    echo "                    Default: 'true'"
    echo "   -<param-name>    A template parameter name"
    echo "   <param-value>    The corresponding template parameter value"
    exit 1
}


source aws_base.shinc
buildCfParams

if [ -z ${stack+x} ]; then
    echo "error: 'stack' parameter must be set"
    usage
fi

stackName=$stack
app=$stack

updateStack $stack $stackName $app "$cfParams" $exec

echo "done!"