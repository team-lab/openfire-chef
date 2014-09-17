name             'openfire-chef'
maintainer       'Gavin Montague'
maintainer_email 'gavin@leftbrained.co.uk'
license          'Apache 2.0'
description      'Installs Openfire Jabber server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.1'

supports         'ubuntu'
supports         'centos'
supports         'redhat'
depends 'java'
depends 'database'
