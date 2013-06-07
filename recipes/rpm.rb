local_rpm_path = "#{Chef::Config[:file_cache_path]}/#{node[:openfire][:rpm_file]}"

rpm_package local_rpm_path do
  source "http://www.igniterealtime.org/downloadServlet?filename=openfire/#{node[:openfire][:rpm_file]}"
  action :install
end

