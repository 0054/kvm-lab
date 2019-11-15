#!/bin/bash

getPlugins=<< EOF
def plugins = jenkins.model.Jenkins.instance.getPluginManager().getPlugins()
pluginsList = []
plugins.toSorted().each {
  pluginsList.add("${it.getShortName()}:${it.getVersion()}")
}

println pluginsList.join('\n')
EOF

curl --user 'user:password' --data-urlencode "script=$(< get_plugins.groovy)" http://rtd-jenkins:8080/scriptText  > plugins_extra.txt
