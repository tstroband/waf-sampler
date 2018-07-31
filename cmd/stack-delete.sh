#!/usr/bin/env bash

function usage() {
    echo "usage:"
    echo "   stack-delete -stack=<stack-name> -profile=<profile>"
    echo "parameters:"
    echo "   -stack           The name of the Cloud Formation stack"
    echo "                    template"
    echo "   -profile         The name of AWS profile to use"
    echo "                    Default: 'default'"
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

deleteStack $stack $stackName

echo "done!"