def plugins = jenkins.model.Jenkins.instance.getPluginManager().getPlugins()
pluginsList = []
plugins.toSorted().each {
  pluginsList.add("${it.getShortName()}:${it.getVersion()}")
}
println pluginsList.join('\n')
