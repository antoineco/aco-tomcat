require 'spec_helper'

describe 'tomcat' do
  let :facts do
    {
      :osfamily                  => 'RedHat',
      :operatingsystemmajrelease => '7',
      :operatingsystem           => 'RedHat',
      :concat_basedir            => '/puppetconcat',
    }
  end
  describe 'general assumptions' do
    it { is_expected.to contain_class('tomcat') }
    it { is_expected.to contain_class('tomcat::params') }
    it { is_expected.to contain_class('tomcat::install') }
    it { is_expected.to contain_class('tomcat::service').that_requires('Class[tomcat::install]') }
    it { is_expected.to contain_class('tomcat::config').that_requires('Class[tomcat::install]') }
  end
  describe 'optional features' do
    context 'extras libraries' do
      let(:params) { { :extras_enable => true } }
      it { is_expected.to contain_class('tomcat::extras').that_requires('Class[tomcat::install]') }
    end
    context 'firewall management' do
      let(:params) { { :manage_firewall => true } }
      it { is_expected.to contain_class('tomcat::firewall') }
    end
  end
end
