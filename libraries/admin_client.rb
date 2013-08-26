class Chef::Recipe::Openfire
  require File.join(File.dirname(__FILE__),"openfire_admin")
  class WhyrunAdmin < OpenfireAdmin
    attr_accessor :can_login
    def server_started?
      @server_started
    end
    def server_started=(s)
      @server_started = s
    end
    def status
      if server_started?
        if logined?
          "logined"
        else
          "login failed"
        end
      else
        "port not opend"
      end
    end
  end
  def self.client(params)
    baseurl = "http#{params[:secure] ? 's':''}://#{params[:host] || 'localhost'}:#{params['port']}"
    if Chef::Config[:why_run]
      client = WhyrunAdmin.new(baseurl)
      begin
        if client.setup_mode?
          client.can_login = false
        end
      rescue Errno::ECONNREFUSED => e
        client.server_started = false
      end
      client
    else
      client = OpenfireAdmin.new(baseurl)
      client.login(params[:username][:password])
    end
  end
  def self.xml_setuped? conf_file
    return false unless File.exists?(conf_file)
    require 'rexml/document'
    doc = REXML::Document.new(open(conf_file)).elements['jive/setup']
    doc and doc.text.to_s == 'true'
  end
end
