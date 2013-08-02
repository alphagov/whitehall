module PolicyHelper
  def array_of_links_to_policies(policies)
    policies.map { |policy| link_to policy.title, public_document_path(policy), class: "policy", id: "policy_#{policy.id}" }
  end
end
