actions :finish
default_action :finish
attribute :console, :required=> true, :callbacks => Chef::Recipe::Openfire.console_validator
attribute :config, :required=> true, :callbacks => Chef::Recipe::Openfire.setup_validator
attribute :database, :required=> false, :callbacks => Chef::Recipe::Openfire.setup_database_validator
attribute :retries, :default => 2

