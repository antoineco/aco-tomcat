require 'spec_helper'

describe 'tomcat::install::archive' do
  let(:pre_condition) { 'class { "tomcat": install_from => "archive" }' }
  let :facts do
    {
      :osfamily                  => 'RedHat',
      :os                        => {:family => 'RedHat'},
      :operatingsystemmajrelease => '7',
      :operatingsystem           => 'RedHat',
      :concat_basedir            => '/puppetconcat'
    }
  end
  describe 'general assumptions' do
    it { is_expected.to contain_class('tomcat') }
    it { is_expected.to contain_class('tomcat::params') }
    it { is_expected.to contain_class('tomcat::install') }
    it do
      is_expected.to contain_group('tomcat').with({
        'ensure' => 'present',
        'system' => true
      })
    end
    it do
      is_expected.to contain_user('tomcat').with({
        'ensure' => 'present',
        'gid'    => 'tomcat',
        'system' => true
      })
    end
  end
  describe 'default params' do
    describe 'RedHat family' do
      let :facts do
        {
          :osfamily       => 'RedHat',
          :os             => {:family => 'RedHat'},
          :concat_basedir => '/puppetconcat'
        }
      end
      context 'on RedHat 7' do
        let :facts do
          super().merge({
            :operatingsystem           => 'RedHat',
            :operatingsystemmajrelease => '7'
          })
        end
        it do
          is_expected.to contain_user('tomcat').with({ 'home' => '/usr/share/tomcat7' })
        end
      end
      context 'on RedHat 6' do
        let :facts do
          super().merge({
            :operatingsystem           => 'RedHat',
            :operatingsystemmajrelease => '6'
          })
        end
        it do
          is_expected.to contain_user('tomcat').with({ 'home' => '/usr/share/tomcat6' })
        end
      end
      context 'on RedHat 5' do
        let :facts do
          super().merge({
            :operatingsystem           => 'RedHat',
            :operatingsystemmajrelease => '5'
          })
        end
        it do
          is_expected.to contain_user('tomcat').with({ 'home' => '/usr/share/tomcat5' })
        end
      end
      context 'on Fedora' do
        let :facts do
          super().merge({
            :operatingsystem           => 'Fedora',
            :operatingsystemmajrelease => '26'
          })
        end
        it do
          is_expected.to contain_user('tomcat').with({ 'home' => '/usr/share/tomcat8' })
        end
      end
    end
    describe 'SuSE family' do
      let :facts do
        {
          :osfamily        => 'Suse',
          :os              => {:family => 'Suse'},
          :concat_basedir  => '/puppetconcat',
        }
      end
      context 'on OpenSuSE' do
        let :facts do
          super().merge({
            :operatingsystem        => 'OpenSuSE',
            :operatingsystemrelease => '42.3'
          })
        end
        it do
          is_expected.to contain_user('tomcat').with({ 'home' => '/usr/share/tomcat8' })
        end
      end
      context 'on SLES 12.0' do
        let :facts do
          super().merge({
            :operatingsystem        => 'SLES',
            :operatingsystemrelease => '12.0'
          })
        end
        it do
          is_expected.to contain_user('tomcat').with({ 'home' => '/usr/share/tomcat7' })
        end
      end
      context 'on SLES 11.3' do
        let :facts do
          super().merge({
            :operatingsystem        => 'SLES',
            :operatingsystemrelease => '11.3'
          })
        end
        it do
          is_expected.to contain_user('tomcat').with({ 'home' => '/usr/share/tomcat6' })
        end
      end
    end
    describe 'Debian family' do
      let :facts do
        {
          :osfamily       => 'Debian',
          :os             => {:family => 'Debian'},
          :concat_basedir => '/puppetconcat',
        }
      end
      context 'on Ubuntu 15.04' do
        let :facts do
          super().merge({
            :operatingsystem        => 'Ubuntu',
            :operatingsystemrelease => '15.04'
          })
        end
        it do
          is_expected.to contain_user('tomcat').with({ 'home' => '/usr/share/tomcat8' })
        end
      end
      context 'on Ubuntu 14.04' do
        let :facts do
          super().merge({
            :operatingsystem        => 'Ubuntu',
            :operatingsystemrelease => '14.04'
          })
        end
        it do
          is_expected.to contain_user('tomcat').with({ 'home' => '/usr/share/tomcat7' })
        end
      end
    end
  end
end
