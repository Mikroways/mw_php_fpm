require 'spec_helper'

describe 'mw_php_fpm_test::delete' do
  before do
    stub_command('test -d /etc/php5/fpm/pool.d || mkdir -p /etc/php5/fpm/pool.d').and_return(true)
  end

  let(:chef_run) do
    runner = ChefSpec::SoloRunner.new(
      platform: 'ubuntu',
      version: '14.04',
      step_into: 'mw_php_fpm')
    runner.converge(described_recipe)
  end

  context 'compiling the test recipe' do
    it 'converges successfully' do
      expect(chef_run).to delete_mw_php_fpm('sample').with(
        session_dir: '/some_dir/fpm/session',
        listen: '/some_dir/var/socket',
        user: 'user'
      )
    end
  end

  context 'stepping into mw_php_fpm[sample] resource' do
    it 'deletes cron to expire session' do
      expect(chef_run).to delete_cron('sample expire sessions').with(
        minute: '09,39',
        command: '[ -d /some_dir/fpm/session ] && find /some_dir/fpm/session -depth -mindepth 1 -maxdepth 1 -type f ! -execdir fuser -s {} \\; -cmin +24 -delete',
        user: 'user')
    end

    it 'includes recipe for php-fpm' do
      expect(chef_run).to include_recipe('php-fpm')
    end

    it 'disables a php-fpm pool' do
      expect(chef_run).to delete_cookbook_file("#{chef_run.node['php-fpm']['pool_conf_dir']}/sample.conf")
    end
  end
end
