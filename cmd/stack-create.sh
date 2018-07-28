#!/usr/bin/env bash

function usage() {
    echo "usage:"
    echo "   stack-create -stack=<stack-name> -env=<env> [-profile=<profile>]"
    echo "                [-<param-name>=<param-value>]*"
    echo "parameters:"
    echo "   -stack           The name of the Cloud Formation stack"
    echo "                    template"
    echo "   -env             The environment"
    echo "                    Valid values: dev|test|acc|prod"
    echo "   -profile         The name of AWS profile to use"
    echo "                    Default: 'default'"
    echo "   -<param-name>    A template parameter name"
    echo "   <param-value>    The corresponding template parameter value"
    exit 1
}

source defaults.shinc
source aws_base.shinc
buildCfParams

if [ -z ${stack+x} ]; then
    echo "error: 'stack' parameter must be specified"
    usage
fi

stackName=$app-$env-$stack

createStack $stack $stackName $env $app $cfParams

echo "done!"