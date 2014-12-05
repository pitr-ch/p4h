Facter.add("p4h_managed_users_list") do
  setcode do
    # find managed users
    Dir.glob("/tmp/a-service-users-db/*").map do |path|
      # skipping users not created by puppet
      # in reality it may be a tag in the DB or anything the target system provides
      next if File.read(path) !~ /puppet managed/
      # report just the name
      File.basename path
    end.flatten.join(";")
  end
end
