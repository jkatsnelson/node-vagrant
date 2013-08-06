name             "node-server"
maintainer       "John Katsnelson"
maintainer_email "john@monsoonco.com"
license          "All rights reserved"
description      "Installs/Configures node_server"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

depends         "minitest-handler", "= 0.1.7"
depends         "apache2", "= 1.6.2"
depends         "nodejs", "= 1.1.2"
depends         "yum", "= 2.2.0"
depends         "varnish", "= 0.9.4"
# Need to pull monit from Github
depends         "monit", "= 0.7.0"