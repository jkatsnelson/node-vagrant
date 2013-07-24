site :opscode
group :integration do
  cookbook "minitest-handler"
end

cookbook "monit", git: "git@github.com:apsoto/monit.git"
cookbook "node-server", path: "./site-cookbooks/node-server"
cookbook "apache2", path: "git@github.com:opscode-cookbooks/apache2.git"
