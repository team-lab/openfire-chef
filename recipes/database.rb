db = node[:openfire][:database]

case db[:type]
when 'postgresql'
  node.default[:openfire][:database][:port] = 5342
  node.default[:openfire][:database][:driver] = "org.postgresql.Driver"
  db = node.openfire.database
  node.default[:openfire][:database][:server_url] = "jdbc:mysql://#{db.host}:#{db.port}/#{db.name}?rewriteBatchedStatements=true"
  node.default[:openfire][:database][:active] = true
when 'mysql'
  node.default[:openfire][:database][:port] = 3306
  node.default[:openfire][:database][:driver] = "com.mysql.jdbc.Driver"
  db = node.openfire.database
  node.default[:openfire][:database][:server_url] = "jdbc:mysql://#{db.host}:#{db.port}/#{db.name}?rewriteBatchedStatements=true"
  node.default[:openfire][:database][:active] = true
when nil
  ;;
else
  raise "don't know how to set a port for db type #{db[:type]}"
end

return unless db[:active]

node.set_unless[:openfire][:database][:local] = (db[:host] == '127.0.0.1' or db[:host] == 'localhost')

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

	end

	include_recipe 'database::mysql'

else
	raise "don't know how to handle database #{db[:type]}"
end
