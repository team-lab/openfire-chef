cookbook_file "#{node[:openfire][:home_dir]}/KeyStoreImport.java" do
  action :create
  source 'KeyStoreImport.java'
end

execute "javac KeyStoreImport.java" do 
  creates "#{node[:openfire][:home_dir]}/KeyStoreImport.class"
  cwd "#{node[:openfire][:home_dir]}"
  action :run
end

execute "import_keys" do 
  not_if "#{node[:java][:java_home]}/bin/keytool -list -keystore #{node[:openfire][:home_dir]}/resources/security/keystore -storepass \"#{node[:openfire][:ssl][:keystore_password]}\" | grep -q \"Your keystore contains [0-9] entries\""
  command "java KeyStoreImport keystore #{node[:openfire][:ssl][:der_cert_chain]} #{node[:openfire][:ssl][:der_key]} \"#{node[:openfire][:ssl][:key_name]}\""
  cwd "#{node[:openfire][:home_dir]}"
end

