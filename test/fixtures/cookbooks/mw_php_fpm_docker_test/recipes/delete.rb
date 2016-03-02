mw_php_fpm_docker 'sample' do
  session_dir '/some_dir/fpm/session'
  listen '/some_dir/var/socket'
  user 'user'
  prefix '/some_dir'
  repo 'some_docker_repo'
  config_file '/some_dir/fpm/config.conf'
  volumes ['/some_dir:/some_dir']
  action :delete
end
