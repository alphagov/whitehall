module PolicyHelper
  def array_of_links_to_policies(policies)
    policies.map { |policy| link_to policy.title, future_policy_path(policy), class: 'policy-link' }
  end

  def future_policy_path(policy)
    policy.is_a?(Future::Policy) ? policy.base_path : public_document_path(policy)
  end
end
