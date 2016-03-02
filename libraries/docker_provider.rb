class Chef
  class Provider
    class MwPhpFpmDocker < Chef::Provider::MwPhpFpm
      provides :mw_php_fpm_docker
      def expire_sessions(action)
        c = cron "#{new_resource.name} expire sessions" do
          minute '09,39'
          command "[ -d #{new_resource.session_dir} ] && find #{new_resource.session_dir} -depth -mindepth 1 -maxdepth 1 -type f ! -execdir fuser -s {} \\; -cmin +#{new_resource.session_lifetime} -delete"
        end
        c.action action
      end

      def delete_service
        docker_container new_resource.name do
          kill_after 10
          action [:stop, :remove]
        end
      end

      def create_service
        config_dir_name = ::File.dirname(new_resource.config_file)
        config_dir = directory config_dir_name do
          recursive true
          not_if { ::Dir.exist?(config_dir_name) }
        end
        config_dir.user new_resource.user

        template "fpm config #{new_resource.config_file}" do
          path new_resource.config_file
          cookbook 'mw_php_fpm'
          source 'fpm_docker_pool.erb'
          owner new_resource.user
          variables(
            prefix: new_resource.prefix,
            listen: new_resource.listen,
            listen_owner: new_resource.listen_owner,
            listen_group: new_resource.listen_group,
            listen_mode: new_resource.listen_mode,
            allowed_clients: new_resource.allowed_clients,
            user: new_resource.user,
            group: new_resource.group,
            process_manager: new_resource.process_manager,
            max_children: new_resource.max_children,
            start_servers: new_resource.start_servers,
            min_spare_servers: new_resource.min_spare_servers,
            max_spare_servers: new_resource.max_spare_servers,
            max_requests: new_resource.max_requests,
            catch_workers_output: new_resource.catch_workers_output,
            security_limit_extensions: new_resource.security_limit_extensions,
            request_terminate_timeout: new_resource.request_terminate_timeout,
            php_options: { 'php_admin_value[session.save_path]' => new_resource.session_dir }
              .merge(new_resource.php_options))
        end

        docker = docker_container new_resource.name do
          action :run
          kill_after 10
          subscribes :restart, "template[fpm config #{new_resource.config_file}]"
        end
        docker.command new_resource.command
        docker.repo new_resource.repo
        docker.volumes(new_resource.volumes)
        docker.user Etc.getpwnam(new_resource.user).uid.to_s if new_resource.run_as_user
      end
    end
  end
end
