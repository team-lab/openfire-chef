action :update do
  client = Chef::Recipe::Openfire::client( new_resource.console )
  props = if client.is_a?(Chef::Recipe::Openfire::WhyrunAdmin) and !client.logined?
             events.whyrun_assumption(@action, @resource, "Can't read current system proerties ( #{client.status} )")
             :whyrun
           else
             client.system_properties
           end
    
  diffs = {}
  new_resource.properties.map{|k,v|
    if props == :whyrun
      diffs[k] = { :new => v, :whyrun => true }
    else
      old = props[k]
      newvalue = v.to_s unless v.nil?
      if old != newvalue
        diffs[k]={ :old => old, :new => v }
      end
    end
  }
  diffs.map{|k,v|
    message = if v[:whyrun]
                v[:new] ? "set #{k} to #{v[:new]}" : "remove #{k}"
              elsif v[:old]
                "change #{k} from \"#{v[:old]}\" to \"#{v[:new]}\""
              elsif v[:new]
                "create #{k} = #{v[:new]}"
              else
                "delete #{k} = #{v[:old]}"
              end
    converge_by(message) do
      props[k]=v[:new]
    end
  }
end

def whyrun_supported?
    true
end

