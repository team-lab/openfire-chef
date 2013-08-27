actions :update
default_action :update
attribute :console, :required=>true, :callbacks => Chef::Recipe::Openfire.console_validator
attribute :properties, :required=>true 

