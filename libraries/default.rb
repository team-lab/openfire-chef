begin
  require 'openfire_admin'
rescue LoadError => e
  Chef::Log.warn("miss load openfire_admin")
  module OpenfireAdmin
  end
end

class Chef::Recipe::Openfire
  class WhyrunAdmin
    attr_accessor :not_setuped
    attr_accessor :client
    def server_stopped?
      @server_stopped
    end
    def server_stopped=(s)
      @server_stopped = s
    end
    def method_missing(name, *args)
      if @clinet
        @client.send name, *args
      else
        case name.to_s
        when "logined?"
          false
        else
          Chef::Log.warn("call undefined method #{name}")
          nil
        end
      end
    end
    def openfire_admin?
      !@client.nil?
    end
    def status
      if openfire_admin?
        if server_stopped?
          "port not opend"
        else
          if not_setuped
            "untill setup"
          else
            if logined?
              "logined"
            else
              "login failed"
            end
          end
        end
      else
        "can't load openfire_admin gem"
      end
    end
  end
  def self.client(params)
    baseurl = "http#{params[:secure] ? 's':''}://#{params[:host] || 'localhost'}:#{params[:secure] ? params[:secure_port] : params[:port]}"
    if Chef::Config[:why_run]
      client = WhyrunAdmin.new
      unless OpenfireAdmin.const_defined?(:Client)
        begin
          require 'openfire_admin'
        rescue LoadError => e
          Chef::Log.warn("miss load openfire_admin")
        end
      end
      if OpenfireAdmin.const_defined?(:Client)
        client.client = OpenfireAdmin.new(baseurl)
        begin
          if client.setup_mode?
            client.not_setuped = true
          else
            client.login(params[:user],params[:password])
          end
        rescue Errno::ECONNREFUSED => e
          client.server_stopped = true
        rescue Exception => e
          raise unless OpenfireAdmin.const_defined?(:ResponseError) and e.is_a?(OpenfireAdmin.const_get(:ResponseError))
        end
      end
    else
      require 'openfire_admin' unless OpenfireAdmin.const_defined?('Client')
      client = OpenfireAdmin.new(baseurl)
      client.login(params[:user], params[:password]) unless client.setup_mode?
    end
    client
  end
  def check_client admin_console
    "ok"
  end
  def self.xml_setuped? conf_file
    return false unless File.exists?(conf_file)
    require 'rexml/document'
    doc = REXML::Document.new(open(conf_file)).elements['jive/setup']
    doc and doc.text.to_s == 'true'
  end
  def self._pv_read(data, k, prefix)
    return data[k] if prefix.empty?
    data = data[prefix.first]
    return nil if data.nil?
    _pv_read(data, k, prefix[1,prefix.size])
  end
  def self._pv_validate(args,prefix=[])
    Hash[*args.map{|k,v|
      if v.is_a? Hash
        _pv_validate(v, prefix + [k]).to_a.flatten
      else
        ["need #{[prefix + [k]].join('.')}", lambda{|h| v === _pv_read(h, k,prefix) }]
      end
    }.flatten]
  end
  def self.validate(args)
    _pv_validate(args)
  end
  def self.console_validator 
    validate(
             :user => String,
             :password => String )
  end
  def self.setup_database_validator
    validate(
             :driver => String,
             :server_url => String,
             :user => String,
             :password => String )

  end
  def self.setup_validator
    validate(
      :locale => String,
      :domain => String,
      :admin_console => {
        :port => Integer,
        :secure_port => Integer,
        :user => String,
        :password => String
      } )
  end
end
