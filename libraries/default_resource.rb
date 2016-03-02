class Chef
  class Resource
    class MwPhpFpm < Chef::Resource::LWRPBase
      provides :mw_php_fpm

      resource_name :mw_php_fpm

      actions :create, :delete

      default_action :create

      attribute :name, kind_of: String, name_property: true, required: true
      attribute :session_dir, kind_of: String, required: true
      attribute :session_lifetime, kind_of: Fixnum, default: 24
      attribute :listen, kind_of: String, required: true
      attribute :listen_owner, kind_of: String
      attribute :listen_group, kind_of: String
      attribute :listen_mode, kind_of: String
      attribute :allowed_clients, kind_of: String
      attribute :user, kind_of: String, required: true
      attribute :group, kind_of: String
      attribute :process_manager, kind_of: String, default: 'dynamic'
      attribute :max_children, kind_of: Fixnum, default: 30
      attribute :start_servers, kind_of: Fixnum, default: 4
      attribute :min_spare_servers, kind_of: Fixnum, default: 2
      attribute :max_spare_servers, kind_of: Fixnum, default: 6
      attribute :max_requests, kind_of: Fixnum, default: 500
      attribute :catch_workers_output, kind_of: [TrueClass, FalseClass], default: true
      attribute :security_limit_extensions, kind_of: [TrueClass, FalseClass, String], default: '.php'
      attribute :access_log, kind_of: String
      attribute :request_terminate_timeout, kind_of: [Fixnum, String], default: 0
      attribute :php_options, kind_of: Hash, default: {}
    end
  end
end
