class Chef
  class Provider
    class MwPhpFpm < Chef::Provider::LWRPBase
      provides :mw_php_fpm
      action :create do
        # directory where sessions will be saved
        dir = directory new_resource.session_dir do
          recursive true
        end
        dir.user new_resource.user

        expire_sessions :create

        create_service
      end

      action :delete do
        expire_sessions :delete
        delete_service
      end

      def delete_service
        include_recipe 'php-fpm'
        php_fpm_pool new_resource.name do
          enable false
        end
      end

      def expire_sessions(action)
        c = cron "#{new_resource.name} expire sessions" do
          minute '09,39'
          command "[ -d #{new_resource.session_dir} ] && find #{new_resource.session_dir} -depth -mindepth 1 -maxdepth 1 -type f ! -execdir fuser -s {} \\; -cmin +#{new_resource.session_lifetime} -delete"
        end
        c.user new_resource.user
        c.action action
      end

      def create_service
        include_recipe 'php-fpm'
        resource = new_resource
        php_fpm_pool new_resource.name do
          listen resource.listen
          listen_owner resource.listen_owner
          listen_group resource.listen_group
          listen_mode resource.listen_mode
          allowed_clients resource.allowed_clients
          user resource.user
          group resource.group
          process_manager resource.process_manager
          max_children resource.max_children
          start_servers resource.start_servers
          min_spare_servers resource.min_spare_servers
          max_spare_servers resource.max_spare_servers
          max_requests resource.max_requests
          catch_workers_output resource.catch_workers_output
          security_limit_extensions resource.security_limit_extensions
          access_log resource.access_log
          request_terminate_timeout resource.request_terminate_timeout
          php_options({ 'php_admin_value[session.save_path]' => resource.session_dir }
                      .merge resource.php_options)
        end
      end
    end
  end
end
