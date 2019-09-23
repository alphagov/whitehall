module PolicyHelper
  def array_of_links_to_policies(policies)
    policies.map { |policy| link_to policy.title, policy_path(policy), class: "policy-link" }
  end

  def policy_path(policy)
    policy.base_path
  end
end
