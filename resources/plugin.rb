actions :install, :uninstall, :reload
default_action :install
attribute :console, :required=>true, :callbacks => Chef::Recipe::Openfire.console_validator
attribute :url, :required=>false, :kind_of => String 

