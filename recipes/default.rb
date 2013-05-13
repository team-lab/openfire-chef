include_recipe "java::default"

db = node[:openfire][:database]
# missing critical db info, skip db configs
node.set_unless[:openfire][:database][:active] = !( db[:type].nil? or db[:password].nil? )

node.set_unless[:openfire][:home_dir] = File.join(node[:openfire][:base_dir],"openfire")
node.set_unless[:openfire][:plugin_dir] = File.join(node[:openfire][:home_dir],'plugins')
node.set_unless[:openfire][:source_checksum] = node[:openfire][:source_checksums][node[:openfire][:source_tarball]]

group node[:openfire][:group] do
  system true
end

user node[:openfire][:user] do
  gid node[:openfire][:group]
  home node[:openfire][:home_dir]
  system true
  shell '/bin/sh'
end

local_tarball_path = "#{Chef::Config[:file_cache_path]}/#{node[:openfire][:source_tarball]}"

remote_file local_tarball_path do
  checksum node[:openfire][:source_checksum]
  source "http://www.igniterealtime.org/downloadServlet?filename=openfire/#{node[:openfire][:source_tarball]}"
  not_if { ::File.exists?(node[:openfire][:home_dir]) }
end

bash "install_openfire" do
  cwd node[:openfire][:base_dir]
  code <<-EOH
    tar xzf #{local_tarball_path}
    chown -R #{node[:openfire][:user]}:#{node[:openfire][:group]} #{node[:openfire][:home_dir]}
    mv #{node[:openfire][:home_dir]}/conf /etc/openfire
    rm /etc/openfire/openfire.xml
    mv #{node[:openfire][:home_dir]}/logs /var/log/openfire
    mv #{node[:openfire][:home_dir]}/resources/security /etc/openfire
  EOH
  creates node[:openfire][:home_dir]
  not_if { ::File.exists?(node[:openfire][:home_dir]) }
end

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

# this directory contains keys, so lock down its permissions
directory '/etc/openfire/security' do
  group 'openfire'
  mode '0700'
  owner 'openfire'
end

if node[:openfire][:database][:active]
  include_recipe "openfire::database"
end

template '/etc/openfire/openfire.xml' do
  group 'openfire'
  mode '0600'
  owner 'openfire'
#  notifies :restart , resources( :service => :openfire )
end

cookbook_file "/etc/init.d/openfire" do
  mode '0755'
end

# on Debian/Ubuntu we use /etc/default instead of /etc/sysconfig
# make a symlink so that openfirectl is happy
link '/etc/sysconfig' do
  to '/etc/default'
  only_if { node[:platform_family] == 'debian' }
end

template '/etc/sysconfig/openfire' do
  mode '0644'
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
