file "#{node[:openfire][:home_dir]}/KeyStoreImport.java" do
  action :create
  source 'KeyStoreImport.java'
end

#
