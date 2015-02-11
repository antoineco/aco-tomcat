require 'spec_helper'

describe 'tomcat::params' do
  let :facts do
    {
      :osfamily                  => 'RedHat',
      :operatingsystemmajrelease => '7',
      :operatingsystem           => 'RedHat'
    }
  end
  it { is_expected.to contain_class('tomcat::params') }
  it { is_expected.to have_resource_count(0) }
end
