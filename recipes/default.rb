
node.default[:openfire][:home_dir] = "#{node.openfire[:base_dir]}/openfire"

case node[:openfire][:install_method]
when "rpm"
  include_recipe 'openfire::rpm'

  link "/etc/openfire" do 
    to "#{node[:openfire][:home_dir]}/conf"
  end

  link "/var/log/openfire" do 
    to "#{node[:openfire][:home_dir]}/logs"
  end

  link "/etc/openfire/security" do
    to "#{node[:openfire][:home_dir]}/resources/security"
  end

when "source"
  include_recipe "java::default"

  group node[:openfire][:group] do
    system true
  end
  
  user node[:openfire][:user] do
    gid node[:openfire][:group]
    home node[:openfire][:home_dir]
    system true
    shell '/bin/sh'
  end

  include_recipe 'openfire::source'

  # link to LSB-recommended directories
  link "#{node[:openfire][:home_dir]}/conf" do
    to '/etc/openfire'
  end

  link "#{node[:openfire][:home_dir]}/logs" do
    to '/var/log/openfire'
  end

  link "#{node[:openfire][:home_dir]}/resources/security" do
    to '/etc/openfire/security'
  end

  cookbook_file "/etc/init.d/openfire" do
    mode '0755'
  end

  template '/etc/sysconfig/openfire' do
    mode '0644'
  end

  # this directory contains keys, so lock down its permissions
  directory '/etc/openfire/security' do
    group node[:openfire][:group]
    mode '0700'
    owner node[:openfire][:group]
  end
end

if node[:openfire][:database][:active]
  include_recipe "openfire::database"
end


template '/etc/openfire/openfire.xml' do
  group node[:openfire][:group]
  mode '0600'
  owner node[:openfire][:group]
  variables({ 
    :setup => Openfire.xml_setuped?(name)
  })
  notifies :restart , "service[openfire]"
end

case node[:platform_family]
when "debian", "ubuntu"
  # on Debian/Ubuntu we use /etc/default instead of /etc/sysconfig
  # make a symlink so that openfirectl is happy
  link '/etc/sysconfig' do
    to '/etc/default'
    only_if { node[:platform_family] == 'debian' }
  end
end


service "openfire" do
  supports :status => true, 
           :stop => true
  action [ :enable, :start ]
end

admin_console = node[:openfire][:config][:admin_console]
admin_port = (admin_console[:secure_port] == -1)? admin_console[:port] : admin_console[:secure_port]
log "And now visit the server on :#{admin_port} to run the openfire wizard." do
  action :nothing
end
