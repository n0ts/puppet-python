require "spec_helper"

describe 'python::pyenv' do
  let(:facts) { default_test_facts }

  let(:default_params) do
    {
      :ensure => 'v20151006',
      :prefix => '/test/boxen/pyenv',
      :user   => 'boxenuser',
    }
  end

  let(:params) { default_params }

  it do
    should contain_class('python')
    should contain_file('/test/boxen/pyenv').with({
      :ensure  => 'directory',
      :owner   => 'boxenuser',
    }).that_requires('Package[pyenv]')
    should contain_file('/cache/pyenv').with({
      :ensure  => 'directory',
      :owner   => 'boxenuser',
    }).that_requires('Package[pyenv]')
  end

  context 'osfamily is Darwin' do
    let(:facts) {
      default_test_facts.merge(:osfamily => 'Darwin')
    }

    it do
      should contain_class('homebrew')
      should contain_package('pyenv')
      should contain_package('pyenv-virtualenv')

      should contain_file('/test/boxen/pyenv').with({
         :ensure  => 'directory',
         :owner   => 'boxenuser',
         :require => 'Package[pyenv]',
      })

      should contain_file('/test/boxen/pyenv/versions').with({
         :ensure  => 'directory',
         :owner   => 'boxenuser',
         :require => 'Package[pyenv]',
      })
    end
  end

  context 'osfamily is not Darwin' do
    let(:facts) {
      default_test_facts.merge(:osfamily => 'Linux', :id => 'root')
    }

    it do
      should_not contain_class('homebrew')
      should_not contain_package('pyenv')

      should contain_repository('/test/boxen/pyenv').with({
        :ensure => 'v20151006',
        :source => 'yyuu/pyenv',
        :user   => 'boxenuser',
      })

       should contain_file('/test/boxen/pyenv/versions').with({
        :ensure => 'symlink',
        :target => '/opt/python',
        :require => 'Repository[/test/boxen/pyenv]',
      })
    end
  end
end

