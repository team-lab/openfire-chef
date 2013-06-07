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
