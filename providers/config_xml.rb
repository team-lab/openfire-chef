def whyrun_supported?
  true
end
require 'rexml/document'
def tr_xml(doc, path, value)
  if path.size == 0
    if value.nil?
      doc.remove
    else
      doc.text = value.to_s
    end
  else
    doc.add_element(path[0]) unless doc.elements[path[0]]
    tr_xml(doc.elements[path[0]], path[1,path.size], value)
  end
end
def xml( path, value )
  tr_xml(@doc.root, path.split('/'), value )
end
action :create do
  old_config = {}
  if ::File.exists?( new_resource.name )
    @doc = REXML::Document.new(open(new_resource.name))
  else
    @doc = REXML::Document.new('<?xml version="1.0" encoding="UTF-8"?>')
    @doc.add_element("jive")
  end
  config = new_resource.config
  database = new_resource.database
  if config[:admin_console]
    xml "adminConsole/port", config[:admin_console][:port] 
    xml "adminConsole/securePort", config[:admin_console][:secure_port] 
  end
  if config[:locale]
    xml "locale", config[:locale]
  end
  if config[:network][:interface]
    xml "network/interface", config[:network][:interface]
  end
  if database and database[:active]
    xml "connectionProvider/className", database[:connectionProvider]
    xml "database/defaultProvider/driver", database[:driver]
    xml "database/defaultProvider/serverURL", database[:server_url]
    xml "database/defaultProvider/username", database[:user]
    xml "database/defaultProvider/password", database[:password]
    xml "database/defaultProvider/testSQL", database[:testSQL]
    xml "database/defaultProvider/testBeforeUse", database[:testBeforeUse]
    xml "database/defaultProvider/testAfterUse", database[:testAfterUse]
    xml "database/defaultProvider/connectionTimeout", database[:connectionTimeout]
  else
    xml "databse", nil
  end
  content = @doc.to_s.sub("<?xml version='1.0' encoding='UTF-8'?>",'<?xml version="1.0" encoding="UTF-8"?>')
  file new_resource.name do
    content content
    owner new_resource.owner
    group new_resource.group
    backup new_resource.backup
    mode new_resource.mode
    action :create
  end
end
