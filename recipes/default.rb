
node.default[:openfire][:home_dir] = "#{node[:openfire][:base_dir]}/openfire"

case node[:openfire][:install_method]
when "rpm"
  include_recipe 'openfire::rpm'
when "source"
  include_recipe 'openfire::source'
end

directory "#{node[:openfire][:home_dir]}" do
  mode "0755"
  group node[:openfire][:group]
  owner node[:openfire][:user]
end

link "/etc/openfire/log4j.xml" do
  to "#{node[:openfire][:home_dir]}/lib/log4j.xml"
end

if node[:openfire][:database][:type]
  include_recipe "openfire::database"
end

openfire_config_xml '/etc/openfire/openfire.xml' do
  group node[:openfire][:group]
  mode '0600'
  owner node[:openfire][:user]
  config node[:openfire][:config]
  database node[:openfire][:database]
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

