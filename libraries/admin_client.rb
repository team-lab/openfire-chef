class Chef::Recipe::Openfire
  require File.join(File.dirname(__FILE__),"openfire_admin")
  class WhyrunAdmin < OpenfireAdmin
    attr_accessor :not_setuped
    def server_stopped?
      @server_stopped
    end
    def server_stopped=(s)
      @server_stopped = s
    end
    def status
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
    end
  end
  def self.client(params)
    baseurl = "http#{params[:secure] ? 's':''}://#{params[:host] || 'localhost'}:#{params['port']}"
    if Chef::Config[:why_run]
      client = WhyrunAdmin.new(baseurl)
      begin
        if client.setup_mode?
          client.not_setuped = true
        else
          client.login(params[:username][:password])
        end
      rescue Errno::ECONNREFUSED => e
        client.server_stopped = true
      end
    else
      client = OpenfireAdmin.new(baseurl)
      client.login(params[:username][:password]) unless client.setup_mode?
    end
    client
  end
  def self.xml_setuped? conf_file
    return false unless File.exists?(conf_file)
    require 'rexml/document'
    doc = REXML::Document.new(open(conf_file)).elements['jive/setup']
    doc and doc.text.to_s == 'true'
  end
end
