local_zip_path = File.join(Chef::Config[:file_cache_path],node[:openfire][:redfire][:source_zip])
war_path = File.join(node[:openfire][:plugin_dir],'redfire.war')

remote_file local_zip_path do
  checksum node[:openfire][:redfire][:source_checksum]
  source "#{node[:openfire][:redfire][:download_base]}#{node[:openfire][:redfire][:source_zip]}"
  only_if { !::File.exists?(war_path) && !::File.exists?(local_zip_path) }
end

bash "install_openfire" do
  cwd node[:openfire][:plugin_dir]
  code <<-EOH
    unzip #{local_zip_path}
    chown -R #{node[:openfire][:user]}:#{node[:openfire][:group]} #{war_path}
  EOH
  not_if { ::File.exists?(war_path) }
end
