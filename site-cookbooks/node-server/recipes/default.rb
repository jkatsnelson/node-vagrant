#
# Cookbook Name:: node_server
# Recipe:: default
#
# Copyright (C) 2013 Blake Tidwell
# 
# All rights reserved - Do Not Redistribute
#

# For resources shared between Apache and Node server
group 'www-data'

# Override defaults to run Apache on port 8080 as a proxy to Node
node.default['apache']['group'] = 'www-data'
node.default['apache']['default_site_enabled'] = false
node.default['apache']['default_modules'].push('proxy')
node.default['apache']['default_modules'].push('proxy_http')
node.default['apache']['listen_ports'] = ["8080"]
include_recipe "apache2"

# Install and start the Node app as a service
include_recipe "nodejs"

# Create the node user/group to run the application
# The group is used for logging
user 'node' do
  gid "www-data"
end

# Default yum package does not add node to the traditional loc on CentOS
link "/usr/bin/node" do
  to "/usr/local/bin/node"
end

# Create or modify the ownership of the app/server directory
execute "own-apache-folder" do
  command "chown -R #{node['apache']['user']}:#{node['apache']['group']} #{node['app_root']}/app"
  action :nothing
end
execute "own-node-folder" do
  command "chown -R node:#{node['apache']['group']} #{node['app_root']}/server"
  action :nothing
end

# Install nodemon for development
if node['app']['environment'] == "development"
  execute "install_nodemon" do
    command "sudo /usr/local/bin/npm install -g nodemon"
  end
end

# Install the NPM packages for the app
execute "npm_install" do
    command "cd #{node['app_root']} && /usr/local/bin/npm install"
end


# Copy over Node Upstart config
template "/etc/init/node.conf" do
    source "node.conf.erb"
    owner "root"
    group "root"
    mode 0644
end

# Create a log folder/file for the node server
directory "/var/log/node" do
 owner "node"
 group "root"
 mode 0775
 action :create
end
file "/var/log/node/node.log" do
 owner "node"
 group "root"
 mode 0664
 action :create
end

# Start the Node service defined in the conf above
service "node" do
    provider Chef::Provider::Service::Upstart
    action :restart
end

# EPEL required to install Monit
include_recipe "yum::epel"

package "monit" do
    action :install
end

# Enable Monit, but do not start yet.
service "monit" do
  action :enable
  enabled true
  supports [:start, :restart, :stop]
end

# Copy over modified Monit conf which enables httpd
# for daemon status
template "/etc/monit.conf" do
  owner "root"
  group "root"
  mode 0700
  source 'monitrc.erb'
  notifies :restart, resources(:service => "monit"), :delayed
end

# Copy over Monit conf for Node app
template "/etc/monit.d/node.monitrc" do
  owner "root"
  group "root"
  source "node.monitrc.erb"
  mode 0700
  notifies :restart, resources(:service => "monit"), :delayed
end

# Now we start the monit service
service "monit" do
  action :start
end

# Create a proxy definition for the Node back-end
web_app "explore" do
  server_name node['fqdn']
  template "node_proxy.conf.erb"
  notifies :restart, 'service[apache2]'
end

# Manually create the varnish cache store directory
directory "/var/lib/varnish/" + node['fqdn'] do
 owner "root"
 group "root"
 mode 0644
 action :create
 recursive true
end

# Install Varnish
node.default['varnish']['dir']     = "/etc/varnish"
node.default['varnish']['default'] = "/etc/sysconfig/varnish"
node.default['varnish']['listen_port'] = 80
node.default['varnish']['backend_host'] = '127.0.0.1'
node.default['varnish']['admin_listen_port'] = 7923
node.default['varnish']['user'] = 'root'
node.default['varnish']['group'] = 'root'
include_recipe "varnish"

# # package "varnish"