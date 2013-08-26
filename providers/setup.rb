def whyrun_supported?
  true
end
action :setup do
  client = new_resource.client
  if client.is_a?(Chef::Recipe::Openfire::WhyrunAdmin) and client.server_stopped?
    events.whyrun_assumption(@action, @resource, "Can't open setup #{client.status}")
  else
    node = new_resource.openfire
    if client.setup_mode?
      setup = client.setup_wizard
      converge_by("setup language #{node[:config][:locale]}") do
        setup.language(node[:config][:locale])
      end
      converge_by("setup server domain=#{node[:config][:domain]} (console port=#{node[:config][:admin_console][:port]} secure=#{node[:config][:admin_console][:secure_port]})") do
        setup.server(node[:config][:domain],node[:config][:admin_console][:port],node[:config][:admin_console][:secure_port])
      end
      unless node[:database][:type]
        converge_by("setup database embedded") do
          setup.database('embedded')
        end
      else
        converge_by("setup database #{node[:database][:driver]} #{node[:database][:server_url]}") do
          setup.database_standard(node[:database][:driver],
                                  node[:database][:server_url],
                                  node[:database][:user],
                                  node[:database][:password])
        end
      end
      converge_by("setup profile default") do
        setup.profile("default")
      end
      converge_by("setup admin #{node[:config][:admin_console][:user]}") do
        setup.admin(node[:config][:admin_console][:user], node[:config][:admin_console][:password])
      end
      converge_by("setup finish") do
        setup.finish()
      end
    end
    unless client.is_a?(Chef::Recipe::Openfire::WhyrunAdmin)
      client.login(node[:config][:admin_console][:user], node[:config][:admin_console][:password])
    end
  end
end
