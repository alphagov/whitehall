module PolicyAdvisoryGroupsHelper
  def list_of_links_to_policy_advisory_groups(policy_advisory_groups)
    policy_advisory_groups.map do |group|
      link_to group.name, policy_advisory_group_path(group), class: 'policy-advisory-group', id: "policy_advisory_group_#{group.id}"
    end.to_sentence.html_safe
  end
end
