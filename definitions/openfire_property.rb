define :openfire_property, :action => :create, :database => {}, :property => {} do
  db = params[:database]
  property = params[:property]
  unless property.empty?
    ruby_block "openfire_property" do
      block do
        conn = ::Mysql.new( db[:host], db[:user], db[:password], db[:name], db[:port] || "3306" )
        ret = {}
        sql = "SELECT name,propValue FROM ofProperty WHERE name in ('#{property.map{|k,v| Mysql::quote k}.join("','")}')"
        # Chef::Log.debug(sql)
        conn.query(sql).each{|name,propValue|
          ret[name]=propValue
        }
        inserter = conn.prepare("INSERT INTO ofProperty (propValue,name) values (?,?)")
        updator = conn.prepare("UPDATE ofProperty SET propValue=? WHERE name=?")
        deleter = conn.prepare("DELETE FROM ofProperty WHERE name=?")
        replaced = false
        property.each{|name,v|
          if v.to_s != ret[name]
            if ret[name].nil?
              Chef::Log.debug("INSERT ofProperty[#{name}] = #{v}")
              inserter.execute( v, name )
            elsif v.nil?
              Chef::Log.debug("DELETE ofProperty[#{name}] = #{ret[name]}")
              deleter.execute( name )
            else
              Chef::Log.debug("UPDATE ofProperty[#{name}] = #{v} => #{ret[name]}")
              updator.execute( v, name )
            end
            replaced = true
          else
            # Chef::Log.debug("UPDATE ofProperty[#{name}] = #{v}")
          end
        }
        if replaced
          notifies :reload , "service[openfire]"
        end
      end
      action params[:action]
    end
  end
end