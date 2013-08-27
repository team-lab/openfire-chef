# for database config, these are required:
# databae type. 'postgres' or 'mysql' or nil (embedded database)
default[:openfire][:database][:type] = nil

# database user name
default[:openfire][:database][:user] = 'openfire'
# database user password
default[:openfire][:database][:password] = nil
# database name
default[:openfire][:database][:name] = 'openfire'
# database host
default[:openfire][:database][:host] = '127.0.0.1'
# database port. if unsetted, derived from :type
default[:openfire][:database][:port] = nil

default[:openfire][:database][:testSQL] = "select 1"
default[:openfire][:database][:testBeforeUse] = "true"
default[:openfire][:database][:testAfterUse] = "true"
default[:openfire][:database][:maxConnections] = 25
default[:openfire][:database][:minConnections] = 5
default[:openfire][:database][:connectionTimeout] = 1.0
default[:openfire][:database][:connectionProvider] = "org.jivesoftware.database.DefaultConnectionProvider"

