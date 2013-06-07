local_rpm_path = "#{Chef::Config[:file_cache_path]}/#{node[:openfire][:rpm_file]}"

remote_file local_rpm_path do
  source "http://www.igniterealtime.org/downloadServlet?filename=openfire/#{node[:openfire][:rpm_file]}"
  not_if "rpm -q openfire"
  notifies :install, "rpm_package[openfire]", :immediately
end

rpm_package "openfire" do
  source local_rpm_path
  only_if {::File.exists?(local_rpm_path)}
  action :nothing
end

file "openfire-rpm-cleanup" do
  path local_rpm_path
  action :delete
end

