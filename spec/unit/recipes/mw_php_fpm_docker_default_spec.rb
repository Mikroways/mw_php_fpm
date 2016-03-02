require 'spec_helper'

describe 'mw_php_fpm_docker_test::default' do
  before do
    mock = double
    allow(mock).to receive(:uid).and_return(1234)
    expect(Etc).to receive(:getpwnam).with('user').and_return(mock)
  end

  let(:chef_run) do
    runner = ChefSpec::SoloRunner.new(
      platform: 'ubuntu',
      version: '14.04',
      step_into: 'mw_php_fpm_docker')
    runner.converge(described_recipe)
  end

  context 'compiling the test recipe' do
    it 'converges successfully' do
      expect(chef_run).to create_mw_php_fpm_docker('sample').with(
        session_dir: '/some_dir/fpm/session',
        listen: '/some_dir/var/socket',
        user: 'user',
        prefix: '/some_dir',
        repo: 'some_docker_repo',
        config_file: '/some_dir/fpm/config.conf'
      )
    end
  end

  context 'stepping into mw_php_fpm_docker[sample] resource' do
    it 'creates session_dir' do
      expect(chef_run).to create_directory('/some_dir/fpm/session').with(
        recursive: true,
        user: 'user')
    end

    it 'creates cron to expire session' do
      expect(chef_run).to create_cron('sample expire sessions').with(
        minute: '09,39',
        command: '[ -d /some_dir/fpm/session ] && find /some_dir/fpm/session -depth -mindepth 1 -maxdepth 1 -type f ! -execdir fuser -s {} \\; -cmin +24 -delete',
        user: 'root')
    end

    it 'creates a php-fpm pool' do
      expect(chef_run).to create_directory('/some_dir/fpm').with(
        recursive: true,
        user: 'user')
      expect(chef_run).to create_template('fpm config /some_dir/fpm/config.conf').with(
        path: '/some_dir/fpm/config.conf',
        cookbook: 'mw_php_fpm',
        source: 'fpm_docker_pool.erb')
    end

    it 'runs a docker container' do
      expect(chef_run).to run_docker_container('sample').with(
        command: 'php-fpm --fpm-config /some_dir/fpm/config.conf',
        repo: 'some_docker_repo',
        user: '1234')
    end
  end
end
