#!/usr/bin/env bash

function usage() {
    echo "usage:"
    echo "   stack-create -stack=<stack-name> -profile=<profile>"
    echo "                -protect=<protect> [-<param-name>=<param-value>]*"
    echo "parameters:"
    echo "   -stack           The name of the Cloud Formation stack"
    echo "                    template"
    echo "   -profile         The name of AWS profile to use"
    echo "                    Default: 'default'"
    echo "   -protect         Add termination protection to the stack"
    echo "                    Valid values: 'true' or 'false'"
    echo "   -<param-name>    A template parameter name"
    echo "   <param-value>    The corresponding template parameter value"
    exit 1
}

source aws_base.shinc
buildCfParams

if [ -z ${stack+x} ]; then
    echo "error: 'stack' parameter must be specified"
    usage
fi

if [ -z ${protect+x} ]; then
    protect='false'
fi

stackName=$stack
app=$stack

createStack $stack $stackName $protect $app "$cfParams"

echo "done!"