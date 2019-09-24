module PolicyGroupsHelper
  def array_of_links_to_policy_groups(policy_groups)
    policy_groups.map do |group|
      link_to group.name, policy_group_path(group), class: "policy-group-link"
    end
  end
end
