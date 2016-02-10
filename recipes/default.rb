package "pam-devel" do
  action :install
end
execute "install monit from source" do
  command <<CMD
  [ -d monit-#{node[:monit][:version]} ] || (curl -LO #{node[:monit][:release_url]}; tar -xvf monit-#{node[:monit][:version]})
  cd monit-#{node[:monit][:version]}
  ./configure
  make
  make install
CMD
  cwd "/tmp"
  not_if "[ \"$(/usr/local/bin/monit --version 2>/dev/null | awk '/Monit version/ { print $5 }')\" == \"#{node[:monit][:version]}\" ]"
end

template "/etc/monitrc" do
  mode 0600
end

directory "/etc/monit.d/" do
  mode 0755
end

template "/etc/init/monit.conf" do
  source "init.erb"
  mode 0644
end
