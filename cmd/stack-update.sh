#!/usr/bin/env bash

function usage() {
    echo "usage:"
    echo "   stack-update -stack=<stack-name> -env=<env> [-profile=<profile>] [-exec=<exec>]"
    echo "                [-<param-name>=<param-value>]*"
    echo "parameters:"
    echo "   -stack           The name of the Cloud Formation stack"
    echo "                    template"
    echo "   -env             The environment"
    echo "                    Valid values: dev|test|acc|prod"
    echo "   -profile         The name of AWS profile to use"
    echo "                    Default: 'default'"
    echo "   -exec            Execute the change set immediately. Set to 'false' "
    echo "                    to review first and execute manually."
    echo "                    Default: 'true'"
    echo "   -<param-name>    A template parameter name"
    echo "   <param-value>    The corresponding template parameter value"
    exit 1
}

source defaults.shinc
source aws_base.shinc
buildCfParams

if [ -z ${stack+x} ]; then
    echo "error: 'stack' parameter must be set"
    usage
fi

stackName=$app-$env-$stack

updateStack $stack $stackName $env $app $cfParams $exec

echo "done!"