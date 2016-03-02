class Chef
  class Resource
    class MwPhpFpmDocker < Chef::Resource::MwPhpFpm
      provides :mw_php_fpm_docker

      self.resource_name = :mw_php_fpm_docker

      attribute :prefix, kind_of: String, required: true
      attribute :config_file, kind_of: String, required: true
      attribute :repo, kind_of: String, required: true
      attribute :run_as_user, kind_of: [TrueClass, FalseClass], default: true
      attribute :command, kind_of: String, default: lazy { |resource| "php-fpm --fpm-config #{resource.config_file}" }
      attribute :volumes, kind_of: Array
    end
  end
end
