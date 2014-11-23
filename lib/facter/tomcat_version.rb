Facter.add(:tomcat_version) do
  confine :kernel => 'Linux'
  tomcat_package_name = Facter.value(:tomcat_package_name)
  setcode do
    Facter::Core::Execution.exec("/bin/rpm -q #{tomcat_package_name} --queryformat \"%{VERSION}\"")
  end
end
