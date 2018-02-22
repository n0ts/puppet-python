require 'spec_helper'

describe 'python::version' do
  let(:facts) { default_test_facts }

  let(:title) { '2.7.12' }

  context 'ensure => present' do
    context 'default params' do
      it do
        should contain_class('python')
        should contain_class('openssl')

        should contain_exec("python-install-#{title}").with({
          :command  => "pyenv install --skip-existing #{title}",
          :cwd      => '/test/boxen/pyenv/versions',
          :provider => 'shell',
          :timeout  => 0,
          :creates  => "/opt/python/#{title}",
          :user     => 'testuser',
          :require  => [ 'Package[readline]', 'Package[openssl]'],
          :notify   => "Exec[python-upgrade-pip-#{title}]",
        })
      end

      it do
        should contain_exec("python-upgrade-pip-#{title}").with({
          :command     => 'pip install --upgrade pip',
          :user        => 'testuser',
          :path        => ["/test/boxen/pyenv/versions/#{title}/bin"],
          :refreshonly => true
        })
      end
    end

    context 'when env is default' do
      it do
        should contain_exec("python-install-#{title}").with_environment([
          'CC=/usr/bin/cc',
          'PYENV_ROOT=/test/boxen/pyenv',
          'PYTHON_BUILD_CACHE_PATH=/cache/pyenv',
        ])
      end
    end

    context 'when env is not nil' do
      let(:params) do
        {
          :env => {'SOME_VAR' => 'foobar'}
        }
      end

      it do
        should contain_exec("python-install-#{title}").with_environment([
          'CC=/usr/bin/cc',
          'PYENV_ROOT=/test/boxen/pyenv',
          'PYTHON_BUILD_CACHE_PATH=/cache/pyenv',
          'SOME_VAR=foobar',
        ])
      end
    end
  end

  context 'ensure => absent' do
    let(:params) do
      {
        :ensure => 'absent'
      }
    end

    it do
      should contain_file("/opt/python/#{title}").with({
        :ensure => 'absent',
        :force  => true,
      })
    end
  end
end
