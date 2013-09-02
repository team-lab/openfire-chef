
class OpenfireAdmin
  class SetupWizard
    def initialize(http)
      @http = http
    end

    def if_not_redirect message, res
      raise ResponceException.new(message,res) unless res.code =="302"
      raise ResponceException.new("setup already run",res) if res["location"] =~ /setup-complete.jsp$/
    end

    def language(locale)
      @http.get("/setup/index.jsp?localeCode=#{locale}&save=Continue"){|res|
        if_not_redirect "cant set locale #{locale}", res
      } 
      self
    end
    def server(domain, embeddedPort=9090, securePort=9091)
      @http.post("/setup/setup-host-settings.jsp",{
        "continue"=>"Continue",
        "domain"=>domain,
        "embeddedPort" => embeddedPort,
        "securePort" => securePort }) do |res|
          if_not_redirect "cant set server", res
      end
      self
    end
    def database(mode="embedded")
      @http.get("/setup/setup-datasource-settings.jsp?next=true&mode=#{mode}&continue=Continue") do |res|
        if_not_redirect "cant set database #{mode}", res
      end
      self
    end
    def database_standard(driver,serverURL,username,password,
                               maxConnections=25,minConnections=5,
                               connectionTimeout=1.0)
      database("standard")
      @http.post("/setup/setup-datasource-standard.jsp",{
        "connectionTimeout" => connectionTimeout.to_s,
        "continue"=>"Continue",
        "driver"=>driver,
        "maxConnections"=>maxConnections,
        "minConnections"=>minConnections,
        "password"=>password,
        "serverURL"=>serverURL,
        "username"=>username}) do |res|
          if_not_redirect "cant set standard database #{serverURL}", res
      end
      self
    end

    def profile(mode="default")
      @http.post("/setup/setup-profile-settings.jsp",{
        "mode" => mode,
        "continue" => "Continue"
      }) do |res|
        if_not_redirect "cant set profile #{mode} #{res.request.body}", res
      end
      self
    end
    def admin(email,password)
      # on get, server store session to admin user
      @http.get("/setup/setup-admin-settings.jsp") do |res|
        raise ResponceException.new("can't get admin settings", res) unless res.code == "200"
      end
      @http.post("/setup/setup-admin-settings.jsp",{"continue"=>"Continue",
                 "email"=>email,
                 "newPassword"=>password,
                 "newPasswordConfirm"=>password,
                 "password"=>password}) do |res|
        if_not_redirect "cant set admin #{email}", res
      end
      self
    end
    def finish()
      @http.get("/setup/setup-finished.jsp") do |res|
        res.code == "200"
      end
    end
  end
end
