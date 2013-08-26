require 'net/http'
require "nokogiri"
require 'open-uri'
$: << File.dirname(__FILE__)
require 'openfire_admin/http_client'
require 'openfire_admin/response_exception'

# openfire admin operator
class OpenfireAdmin
  NBSP = Nokogiri::HTML("&nbsp;").text

  # pure admin console client
  class AdminClient
    def initialize(loginurl)
      @http = HttpClient.new(URI.parse(loginurl))
    end
    def login(username, pass)
			@http.post( "/login.jsp" , {
					"login"=> "true",
					"password"=>pass,
					"url"=>"/index.jsp",
					"username"=>username}) do |res|
				raise ResponceException.new("can't login",res) unless res.code == "302"
			end
    end
    def remove_property(name)
      @http.post('/server-properties.jsp', 'propName' => name, 'del'=>'true') do |res|
        raise ResponceException.new("cant save",res) if res.code != "302" or res['location'] !~ /deletesuccess=true$/
      end
    end
    def set_property(name, value)
      @http.post('/server-properties.jsp', 'propName' => name, 'propValue'=>value.to_s, 'save'=>'Save Property') do |res|
        raise ResponceException.new("cant save",res) if res.code != "302"
      end
    end
    def get_property(name)
      @http.post("/server-properties.jsp", "edit"=>"true", "propName"=>name) do |res|
        ta = Nokogiri::HTML(res.body).at('textarea[name=propValue]')
        raise ResponceException.new("not found textarea",res) unless ta
        ta.content.to_s
      end
    end
    def get_properties
      ret = {}
	    @http.get("/server-properties.jsp") do |res|
        raise ResponceException.new("can't read",res) unless res.code== "200"
        doc = Nokogiri::HTML(res.body)
        doc.search('//h1/parent::node()//table/tbody/tr[@class=""]').each do |tr|
          ret[tr.at('td span')[:title]]= tr.at('td[2] span')[:title]
        end
		  end
      ret
    end
    def get_installed_plugins
      @http.get("/plugin-admin.jsp") do |res|
        doc =Nokogiri::HTML(res.body)
        doc.at('h1').parent.at('table').search('tbody tr[valign=top]').map do |tr|
          img = tr.at('a[href*="reloadplugin="]')
          if img
            {
              :key => img[:href].match(/\?reloadplugin=([^"'&>]*)/)[1],
              :name => tr.search('td')[1].content.gsub(NBSP,' ').strip,
              :description => tr.search('td')[3].content.strip,
              :version => tr.search('td')[4].content.strip
            }
          end
        end
      end
    end
    def install_plugin(url)
      @http.post("/dwr/exec/downloader.installPlugin.dwr",
        "callCount"=>"1",
        "c0-scriptName"=>"downloader",
        "c0-methodName"=>"installPlugin",
        "c0-id"=>"0",
        "c0-param0"=>"string:#{url}",
        "c0-param1"=>"string:14867746",
        "xml"=>"true" ) do |res|
        raise ResponceException.new("plugin install fail",res) unless res.code == "200" and res.body =~ /s0\.successfull=/
      end
    end
    def reload_plugin(key)
	    @http.get("/plugin-admin.jsp?reloadplugin=#{key}") do |res|
				raise ResponceException.new("cant reload",res) if res.code != "302" or res['location'] !~ /reloadsuccess=true/
		  end
    end
    def uninstall_plugin(key)
	    @http.get("/plugin-admin.jsp?deleteplugin=#{key}") do |res|
				raise ResponceException.new("cant delete",res) if res.code != "302" or res['location'] !~ /deletesuccess=true/
		  end
    end
    def system_cache
	    @http.get("/system-cache.jsp") do |res|
        Nokogiri::HTML(res.body).search('input[type=checkbox][name=cacheID]').map{|i|
          {
            :cacheID => i[:value],
            :name => i.ancestors("tr").first.search("td td")[1].content.strip
          }
        }
		  end
    end
    def system_cache_clear(cacheID)
	    @http.post("/system-cache.jsp","cacheID"=>cacheID, "clear"=>"Clear") do |res|
        ! Nokogiri::HTML(res.body).at("div[class='jive-success']").nil?
      end
    end
    def setup_mode?
      @http.get("/login.jsp") do |res|
        res.code == "302" and res["location"] =~ "/setup/"
      end
    end
  end
  def setup_mode?
    @client.setup_mode?
  end
  def setup
    require File.join(File.dirname(__FILE__),"openfire_admin_setup")
    SetupWizard.new(@http)
  end

  def initialize(loginurl="http://localhost:9090")
	  @client = AdminClient.new(loginurl)
	end
  def logined?
    @logined
  end

  def login(username, password)
    @client.login(username, password)
    @logined = true
  end

  # System property map
  class PropertyMap
    def initialize(client)
      @client = client
      reload
    end

    def inspect
      @cache.inspect
    end

    # get system property
    def []( name )
      v = @cache[name]
      v = @client.get_property(name) if v.nil? and @cache.has_key?(name)
      v
    end

    # reload cache
    def reload
      @cache = @client.get_properties
      self
    end

    # remove property
    def remove(name)
      @client.remove_property(name)
    end

    # set/add property
    def []=(name,value)
      if value.nil?
        remove(name)
      else
        @client.set_property(name, value)
        @cache[name]=value
      end
    end
  end

  # get properties
	def system_properties
    PropertyMap.new(@client)
	end

  # cache control. this instance can clear cache.
  class SystemCache
    attr_reader :cacheID, :name
    def initialize(client, cacheID, name)
      @client = client
      @cacheID = cacheID
      @name = name
    end
    def to_s
      "#<#{self.class} (#{@cacheID})#{name.inspect}>"
    end
    # clear cache
    def clear
      @client.system_cache_clear( @cacheID )
    end
  end

  # return SystemCache array
  def system_cache
    @client.system_cache.map{|c| SystemCache.new( @client, c[:cacheID], c[:name] )}
  end

  # plugin abstract class
	class Plugin
	  attr_accessor :name, :description, :version
    attr_reader :key
		def initialize(client, key)
		  @client = client
      @key = key.downcase
		end
    def inspect
      to_s
    end
    def to_s
      "#<#{self.class} #{key} #{version} (#{name.inspect} #{description.inspect})>"
    end
    def eql?(obj)
      case obj
      when Plugin
        self.key == obj.key
      when String
        self.key == obj.downcase
      else
        false
      end
    end
	end

  # installed plugin. this instance can uninstall and reload
	class InstalledPlugin < Plugin
    # reload plugin
		def reload
      @client.reload_plugin(key)
		end

    # uninstall plugin
		def uninstall
      @client.uninstall_plugin(key)
		end
	end

  # available plugin. this can install
	class AvailablePlugin < Plugin
	  attr_accessor :url

    # install plugin
		def install
      @client.install_plugin(url)
    end
	end

  # plugin list array. this can find plugin by key.
  class PluginList < Array
		def [](name)
      if name.is_a?(String)
		    self.find{|p| p.eql? name }
      else
        super
      end
		end
	end

  # plugins list array of available plugins.
  # if you need not installed plugins, ( self.available_plugins - self.install_plugin )
	def available_plugins
	  ret = PluginList.new
	  doc = Nokogiri::XML(open("http://www.igniterealtime.org/projects/openfire/versions.jsp").read)
		doc.search('plugin').each do |tr|
			p = AvailablePlugin.new(@client, tr[:url].match(/\/([^\.\/]+)\.[^\/.]+$/)[1])
			p.name = tr[:name]
			p.description = tr[:description]
			p.version = tr[:latest]
			p.url = tr[:url]
			ret << p
		end
		ret
	end

  # plugins list array of installed plugins
	def installed_plugins
	  ret = PluginList.new
    @client.get_installed_plugins.each{|p|
      r = InstalledPlugin.new(@client, p[:key])
      r.name = p[:name]
      r.description = p[:description]
      r.version = p[:version]
      ret << r
    }
		ret
	end
end
