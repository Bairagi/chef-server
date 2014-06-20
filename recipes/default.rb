# Cookbook Name:: chef-server
# Recipe:: default


# set the hostname for chef-server mandates fqdn
execute "set_hostname" do
  command "hostname #{node['chef-server']['fqdn']}"
  not_if "hostname | grep #{node['chef-server']['fqdn']}"
end

script "set_fqdn" do
  interpreter "bash"
  user "root"
  code <<-EOH
    hostname #{node['chef-server']['fqdn']}
    echo "#{node['chef-server']['fqdn']}" >> /etc/hostname
    echo "127.0.0.1 #{node['chef-server']['fqdn']}" >> /etc/hosts    
  EOH
  not_if "hostname -f | grep #{node['chef-server']['fqdn']}"
end

execute "get_chef-server" do
  cwd "/opt"
  command "wget #{node['chef-server']['url']}/#{node['chef-server']['package_file']}"
  not_if { File.exists?("/opt/#{node['chef-server']['package_file']}") }
end

execute "install_chef-server" do
  cwd "/opt"
  command "dpkg -i #{node['chef-server']['package_file']}"
  notifies :run, 'execute[reconfigure-chef-server]', :immediately
end


# reconfigure the installation
execute 'reconfigure-chef-server' do
  command 'chef-server-ctl reconfigure'
  action :nothing
end

