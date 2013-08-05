module PolicyAdvisoryGroupsHelper
  def array_of_links_to_policy_advisory_groups(policy_advisory_groups)
    policy_advisory_groups.map do |group|
      link_to group.name, policy_advisory_group_path(group)
    end
  end
end
