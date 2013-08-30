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

local_tarball_path = "#{Chef::Config[:file_cache_path]}/#{node[:openfire][:source_tarball]}"

remote_file local_tarball_path do
  checksum node[:openfire][:source_checksum]
  source "http://www.igniterealtime.org/downloadServlet?filename=openfire/#{node[:openfire][:source_tarball]}"
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
  owner node[:openfire][:user]
end

