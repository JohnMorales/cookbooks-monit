%w[ pam-devel make autoconf automake gcc file openssl-devel tar upstart ].each do |pkg|
  package pkg do
    action :install
  end
end

execute "install monit from source" do
  command <<CMD
  [ -d monit-#{node[:monit][:version]} ] || (curl -LO #{node[:monit][:release_url]}; tar -xvf #{File.basename(node[:monit][:release_url])})
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

execute "start monit" do
  command "/sbin/start monit"
  not_if "/sbin/status monit &>/dev/null"
end
