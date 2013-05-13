db = node[:openfire][:database]
node.set_unless[:openfire][:database][:local] = (db[:host] == '127.0.0.1' or db[:host] == 'localhost')

case db[:type]
when 'postgresql'
  node.set_unless[:openfire][:database][:port] = 5342
  node.set_unless[:openfire][:database][:driver] = "org.postgresql.Driver"
  node.set_unless[:openfire][:database][:server_url] = "jdbc:#{db[:type]}://#{db[:host]}:#{db[:port]}/#{db[:name]}"
when 'mysql'
  node.set_unless[:openfire][:database][:port] = 3306
  node.set_unless[:openfire][:database][:driver] = "com.mysql.jdbc.Driver"
  node.set_unless[:openfire][:database][:server_url] = "jdbc:#{db[:type]}://#{db[:host]}:#{db[:port]}/#{db[:name]}"
else
  raise "don't know how to set a port for db type #{db[:type]}"
end

return unless db[:active]

case db[:type]

#when 'mysql'
	# untested

when 'postgresql'
	if db[:local]
		# set up the database and user
		include_recipe 'postgresql::server'

		conn = {
			:host => '127.0.0.1',
			:port => db[:port],
			:username => 'postgres',
			:password => node[:postgresql][:password][:postgres]
		}

		postgresql_database_user db[:user] do
			action :create
			connection conn
			password db[:password]
		end

		postgresql_database db[:name] do
			action :create
			connection conn
			owner db[:user]
		end
	end

	include_recipe 'database::postgresql'

when 'mysql'
	if db[:local]
		# set up the database and user
		include_recipe 'mysql::server'

		conn = {
			:host => '127.0.0.1',
			:port => db[:port],
			:username => 'root',
			:password => node[:mysql][:server_root_password]
		}

		mysql_database_user db[:user] do
			action :grant
			connection conn
			database_name db[:name]
			password db[:password]
		end

		mysql_database "import_ddl" do
      connection conn
			database_name db[:name]
      sql { 
      	::File.open("#{node[:openfire][:home_dir]}/resources/database/openfire_mysql.sql").read
      }
      action :nothing
    end

		mysql_database db[:name] do
			action :create
			connection conn
			owner db[:user]
			notifies :query, resources( :mysql_database  => "import_ddl" ), :immediately
		end

	  openfire_property "mysql" do
	  	database node[:openfire][:database]
	  	property node[:openfire][:property]
	    action :create
	  end

	end

	include_recipe 'database::mysql'

else
	raise "don't know how to handle database #{db[:type]}"
end
