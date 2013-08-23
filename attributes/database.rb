# for database config, these are required:
default[:openfire][:database][:type] = nil
default[:openfire][:database][:password] = nil

# these are optional:
default[:openfire][:database][:name] = 'openfire'
default[:openfire][:database][:user] = 'openfire'
default[:openfire][:database][:host] = '127.0.0.1'
default[:openfire][:database][:port] = nil # (derived from :type)

