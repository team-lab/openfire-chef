actions :create
default_action :create
attribute :config
attribute :database

#include Chef::Mixin::Securable
attribute :owner, :regex => Chef::Config[:user_valid_regex]
attribute :mode, :callbacks => { "not in valid numeric range" => lambda { |m|
  if m.kind_of?(String)
    m =~ /^0/ || m="0#{m}"
  end

  # Windows does not support the sticky or setuid bits
  if Chef::Platform.windows?
    Integer(m)<=0777 && Integer(m)>=0
  else
    Integer(m)<=07777 && Integer(m)>=0
  end
} }
attribute :group, :regex => Chef::Config[:group_valid_regex]
attribute :backup, :kind_of => [ Integer, FalseClass ]

