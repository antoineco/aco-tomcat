require 'spec_helper'

describe 'tomcat::install::package' do
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
end
