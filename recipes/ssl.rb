cookbook_file "#{node[:openfire][:home_dir]}/KeyStoreImport.java" do
  action :create
  source 'KeyStoreImport.java'
end

exec "javac KeyStoreImport.java" do 
  creates "#{node[:openfire][:home_dir]}/KeyStoreImport.class"
  cwd "#{node[:openfire][:home_dir]}"
end
