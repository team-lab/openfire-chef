class Chef::Recipe::Openfire
  def self.client(params)
    baseurl = "http#{params[:secure] ? 's':''}://#{params[:host] || 'localhost'}:#{params['port']}"
    OpenfireAdmin.new(params[:user], params[:password], baseurl )
  end
end
