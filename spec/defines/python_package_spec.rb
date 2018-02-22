require 'spec_helper'

describe 'python::package' do
  let(:facts) { default_test_facts }

  let(:title) { 'virtualenv for 2.7.12' }

  let(:params) do
    {
      :package => 'virtualenv',
      :version => '1.11.2',
      :python  => '2.7.12',
    }
  end

  it do
    should contain_class('python')

    should contain_pyenv_package("virtualenv for #{params[:python]}").with({
      :package       => 'virtualenv',
      :version       => params[:version],
      :pyenv_root    => '/test/boxen/pyenv',
      :pyenv_version => params[:python],
    })
  end
end
