actions :install, :uninstall, :reload
default_action :install
attribute :client, :required=>true, :kind_of => OpenfireAdmin
attribute :url, :required=>false, :kind_of => String 

