if defined?(ChefSpec)
  if ChefSpec.respond_to?(:define_matcher)
    ChefSpec.define_matcher :mw_php_fpm
    ChefSpec.define_matcher :mw_php_fpm_docker
  end

  %i(create delete).each do |action|
    define_method("#{action}_mw_php_fpm") do |name|
      ChefSpec::Matchers::ResourceMatcher.new(:mw_php_fpm, action, name)
    end

    define_method("#{action}_mw_php_fpm_docker") do |name|
      ChefSpec::Matchers::ResourceMatcher.new(:mw_php_fpm_docker, action, name)
    end
  end

end
