#Delete group_memberships
Group.find_each do |group|
  group.group_memberships.delete_all
end

Group.destroy_all
