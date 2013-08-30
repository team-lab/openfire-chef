def whyrun_supported?
  true
end
def create_admin_user
  config = new_resource.config
  console = new_resource.console.merge(:user=>"admin")
  temp_admin_client = Chef::Recipe::Openfire.client(console)
  if temp_admin_client.is_a?(Chef::Recipe::Openfire::WhyrunAdmin) or !temp_admin_client.client.user_exists?( config[:admin_console][:user] )
    converge_by("create user #{config[:admin_console][:user]}") do
      temp_admin_client.client.create_user(
        new_resource.console[:user],
        new_resource.console[:password],
        new_resource.console[:user],
        new_resource.console[:user],
        true)
    end
  end
end
action :finish do
  client = Chef::Recipe::Openfire::client( new_resource.console )
  if client.is_a?(Chef::Recipe::Openfire::WhyrunAdmin) and client.server_stopped?
    events.whyrun_assumption(@action, @resource, "Can't open setup #{client.status}")
  else
    config = new_resource.config
    db = new_resource.database
    if client.setup_mode?
      setup = client.setup_wizard
      converge_by("setup language #{config[:locale]}") do
        setup.language(config[:locale])
      end
      converge_by("setup server domain=#{config[:domain]} (console port=#{config[:admin_console][:port]} secure=#{config[:admin_console][:secure_port]})") do
        setup.server(config[:domain],config[:admin_console][:port],config[:admin_console][:secure_port])
      end
      unless db
        converge_by("setup database embedded") do
          setup.database('embedded')
        end
      else
        converge_by("setup database #{db[:driver]} #{db[:server_url]}") do
          setup.database_standard(db[:driver], db[:server_url], db[:user], db[:password],
                                 db[:maxConnections],db[:minConnections],db[:connectionTimeout])
        end
      end
      converge_by("setup profile default") do
        setup.profile("default")
      end
      converge_by("setup admin") do
        setup.admin("admin", new_resource.console[:password])
      end
      converge_by("setup finish") do
        setup.finish()
        sleep 3
      end
      if config[:admin_console][:user] != "admin"
        create_admin_user
      end
      unless client.is_a?(Chef::Recipe::Openfire::WhyrunAdmin)
        client.login(config[:admin_console][:user], config[:admin_console][:password])
      end
    end
  end
end
