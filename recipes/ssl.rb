cookbook_file "#{node[:openfire][:home_dir]}/KeyStoreImport.java" do
  action :create
  source 'KeyStoreImport.java'
end

exec "build KeyStoreImport.java" do 
  command "javac KeyStoreImport.java"
  creates "#{node[:openfire][:home_dir]}/KeyStoreImport.class"
  cwd "#{node[:openfire][:home_dir]}"
end
