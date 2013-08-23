action :update do
  @props = new_resource.client.system_properties
  diffs = {}
  new_resource.properties.map{|k,v|
    old = @props[k]
    newvalue = v.to_s unless v.nil?
    if old != newvalue
      diffs[k]=v
    end
  }
  diffs.map{|k,v|
    message = if old
          "change #{k} from #{old} to #{v}"
              elsif newvalue
          "create #{k} = #{newvalue}"
              else
          "delete #{k} = #{old}"
              end
    converge_by(message) do
      @props[k]=v
    end
  }
end

def whyrun_supported?
    true
end

