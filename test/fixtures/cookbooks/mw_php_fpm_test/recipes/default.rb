mw_php_fpm 'sample' do
  session_dir '/some_dir/fpm/session'
  listen '/some_dir/var/socket'
  user 'user'
end
