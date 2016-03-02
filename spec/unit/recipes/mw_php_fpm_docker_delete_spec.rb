require 'spec_helper'

describe 'mw_php_fpm_docker_test::delete' do
  let(:chef_run) do
    runner = ChefSpec::SoloRunner.new(
      platform: 'ubuntu',
      version: '14.04',
      step_into: 'mw_php_fpm_docker')
    runner.converge(described_recipe)
  end

  context 'compiling the test recipe' do
    it 'converges successfully' do
      expect(chef_run).to delete_mw_php_fpm_docker('sample').with(
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
    it 'removes cron to expire session' do
      expect(chef_run).to delete_cron('sample expire sessions').with(
        minute: '09,39',
        command: '[ -d /some_dir/fpm/session ] && find /some_dir/fpm/session -depth -mindepth 1 -maxdepth 1 -type f ! -execdir fuser -s {} \\; -cmin +24 -delete',
        user: 'root')
    end

    it 'removes a docker container' do
      expect(chef_run).to stop_docker_container('sample')
      expect(chef_run).to remove_docker_container('sample')
    end
  end
end
