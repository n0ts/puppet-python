require 'spec_helper'

describe 'python' do
  let(:facts) { default_test_facts }

  let(:default_params) do
    {
      :prefix => '/test/boxen',
    }
  end

  let(:params) { default_params }

  it { should contain_class("python::pyenv") }

  context "osfamily is Darwin" do
    let(:facts) {
      default_test_facts.merge(:osfamily => "Darwin")
    }

    it { should contain_class("boxen::config") }
    it { should contain_boxen__env_script("pyenv") }
  end

  context "osfamily is not Darwin" do
    let(:facts) {
      default_test_facts.merge(:osfamily => "Linux", :id => "root")
    }

    it { should_not contain_class("boxen::config") }
    it { should_not contain_boxen__env_script("python") }
  end
end
