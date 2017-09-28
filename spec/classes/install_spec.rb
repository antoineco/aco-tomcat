require 'spec_helper'

describe 'tomcat::install' do
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
  end
  describe 'main class not included' do
    let(:pre_condition) {}
    it do
      is_expected.to raise_error(Puppet::Error, /You must include the tomcat base class before using any tomcat sub class/)
    end
  end
  describe 'install tomcat' do
    context 'from package' do
      it { is_expected.to contain_class('tomcat::install::package') }
      it { is_expected.not_to contain_class('tomcat::install::archive') }
    end
    context 'from archive' do
      let(:pre_condition) { 'class { "tomcat": install_from => "archive" }' }
      it { is_expected.to contain_class('tomcat::install::archive') }
      it { is_expected.not_to contain_class('tomcat::install::package') }
    end
  end
  describe 'extras packages' do
    context 'default installation' do
      it { is_expected.not_to contain_package('tomcat native library') }
    end
    context 'with tomcat native' do
      let(:pre_condition) { 'class { "tomcat": tomcat_native => true }' }
      it { is_expected.to contain_package('tomcat native library') }
    end
  end
end
