node.default[:openfire][:rpm_file] = "openfire-#{node[:openfire][:version]}-#{node[:openfire][:release]}.i386.rpm"
local_rpm_path = "#{Chef::Config[:file_cache_path]}/#{node[:openfire][:rpm_file]}"

version=`rpm -q --queryformat='\%{VERSION}-\%{RELEASE}' openfire`
version="" if $? !=0
need_install= version == "#{node[:openfire][:version]}-#{node[:openfire][:release]}"

remote_file local_rpm_path do
  source "http://www.igniterealtime.org/downloadServlet?filename=openfire/#{node[:openfire][:rpm_file]}"
	not_if{ need_install }
end

rpm_package "openfire" do
  source local_rpm_path
	#version node[:openfire][:version]
	not_if{ need_install }
end

link "/etc/openfire" do 
  to "#{node[:openfire][:home_dir]}/conf"
end

link "/var/log/openfire" do 
  to "#{node[:openfire][:home_dir]}/logs"
end

link "/etc/openfire/security" do
  to "#{node[:openfire][:home_dir]}/resources/security"
end

# this directory contains keys, so lock down its permissions
directory "#{node[:openfire][:home_dir]}/resources/security" do
  group node[:openfire][:group]
  mode '0700'
  owner node[:openfire][:user]
end

