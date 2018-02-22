require 'spec_helper'

describe 'python::alias' do
  let(:facts) { default_test_facts }

  let(:title) { '2.7' }

  let(:default_params) { {
    :to     => '2.7.14',
    :ensure => 'installed',
  } }

  let(:params) { default_params }

  it do
    should contain_python__version(default_params[:to])
    should contain_file("/opt/python/#{title}").with({
      :ensure => 'symlink',
      :force  => true,
      :target => "/opt/python/#{default_params[:to]}",
    }).with_require("Python::Version[#{default_params[:to]}]")
  end

  context 'ensure => absent' do
    let(:params) { default_params.merge(:ensure => 'absent') }
    it do
      should_not contain_python__version(default_params[:to])
      should contain_file("/opt/python/#{title}").with_ensure('absent')
    end
  end
end
