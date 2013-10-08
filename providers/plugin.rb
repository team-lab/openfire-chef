def whyrun_supported?
    true
end
def current_plugins console
  @client = Chef::Recipe::Openfire::client( console )
  if @client.is_a?(Chef::Recipe::Openfire::WhyrunAdmin) and !@client.logined?
     events.whyrun_assumption(@action, @resource, "Can't read current installed plugins #{@client.status}")
     Hash.new
  else
    @client.installed_plugins
  end
end

action :install do
  plugin = current_plugins(new_resource.console)[new_resource.name]
  unless plugin
    if new_resource.url
      converge_by("install plugin from #{new_resource.url}") do
        @client.install_plugin(new_resource.url)
      end
    else
      plugin = @client.available_plugins[new_resource.name]
      raise "can't find plugin key '#{new_resource.name}'" unless plugin
      converge_by("install from available plguins \"#{plugin.name}\"") do
        plugin.install
      end
    end
  end
end
action :reload do
  plugin = current_plugins(new_resource.console)[new_resource.name]
  if plugin
    converge_by("reload plguin \"#{plugin.name}\"") do
      plugin.reload
    end
  end
end
action :uninstall do
  plugin = current_plugins(new_resource.console)[new_resource.name]
  if plugin
    converge_by("uninstall plguin \"#{plugin.name}\"") do
      plugin.uninstall
    end
  end
end
