# openfire admin operator
class OpenfireAdmin
  # unexpected response found exception
	class ResponceException < Exception
	  attr_reader :response
	  def initialize(message,res)
      case res
      when Net::HTTPSuccess
        doc = Nokogiri::HTML(res.body)
        msgs = ( doc.search('.jive-error-text, .error') || [] ).map{|c| c.text.strip}
        if msgs.empty?
          super(message)
        else
          super("#{message} [#{msgs.join(' / ')}]")
        end
      when Net::HTTPRedirection
        super("#{message} redirct to=>#{res['location']}")
      when Net::HTTPNotFound
        super("#{message} Not found #{res.request.path}")
      else
        super("#{message} res.code=#{res.code}")
      end

			@response = res
		end
	end
end
