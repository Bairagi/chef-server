# Cookbook Name:: chef-server
# Recipe:: default


# set the hostname for chef-server mandates fqdn
execute "set_hostname" do
  command "hostname #{node['chef-server']['fqdn']}"
  not_if "hostname | grep #{node['chef-server']['fqdn']}"
end

file "/etc/hostname" do
  mode "0644"
  content node['chef-server']['fqdn']
end

script "add_hostentry" do
  interpreter "bash"
  user "root"
  code <<-EOH
    echo "127.0.0.1 #{node['chef-server']['fqdn']}" >> /etc/hosts    
  EOH
  not_if "grep -ri #{node['chef-server']['fqdn']} /etc/hosts"
end

execute "downloading chef-server" do
  cwd "/opt"
  command "wget #{node['chef-server']['url']}/#{node['chef-server']['package_file']}"
  not_if { File.exists?("/opt/#{node['chef-server']['package_file']}") }
end

execute "installing chef-server" do
  cwd "/opt"
  command "dpkg -i #{node['chef-server']['package_file']}"
  notifies :run, 'execute[reconfigure-chef-server]', :immediately
end

# chef-server installation hack for lxc
cookbook_file "/opt/chef-server/embedded/cookbooks/chef-server/templates/default/postgresql.conf.erb" do
  mode "0644"
  source "postgresql.conf"
end

# reconfigure the installation
execute 'reconfigure-chef-server' do
  action :nothing
  command 'chef-server-ctl reconfigure'
end

