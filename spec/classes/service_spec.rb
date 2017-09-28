require 'spec_helper'

describe 'tomcat::service' do
  let(:pre_condition) { 'include tomcat' }
  let :facts do
    {
      :osfamily                  => 'RedHat',
      :os                        => {:family => 'RedHat'},
      :operatingsystemmajrelease => '7',
      :operatingsystem           => 'RedHat',
      :concat_basedir            => '/puppetconcat',
    }
  end
  describe 'general assumptions' do
    it { is_expected.to contain_class('tomcat') }
    it { is_expected.to contain_class('tomcat::params') }
    it { is_expected.to contain_class('tomcat::install') }
  end
  describe 'main class not included' do
    let(:pre_condition) {}
    it do
      is_expected.to raise_error(Puppet::Error, /You must include the tomcat base class before using any tomcat sub class/)
    end
  end
  describe 'create tomcat service' do
    context 'from package' do
      it { is_expected.to contain_class('tomcat::service::package') }
      it { is_expected.not_to contain_class('tomcat::service::archive') }
    end
    context 'from archive' do
      let(:pre_condition) { 'class { "tomcat": install_from => "archive" }' }
      it { is_expected.to contain_class('tomcat::service::archive') }
      it { is_expected.not_to contain_class('tomcat::service::package') }
    end
  end
end
