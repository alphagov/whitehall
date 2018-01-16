
def policies_to_organisations(policies)
  organisation_content_ids = policies.inject([]) do |memo, policy|
    orgs = policy["links"]["organisations"]
    if orgs
      orgs.each do |org|
        memo << org["content_id"]
      end
    end

    memo
  end
  organisation_content_ids = organisation_content_ids.uniq

  Organisation.where(content_id: organisation_content_ids)
end

def top_3_policy_results(organisation)
  Whitehall.search_client.search(
    filter_organisations: [organisation.slug],
    filter_format: "policy",
    count: "3",
    order: "-public_timestamp"
  ).results
end

def policy_content_id(policies, policy_link)
  policies
    .find { |policy| policy["base_path"] == policy_link }
    .fetch("content_id")
end


policies = Whitehall.content_register.entries("policy")

policies_to_organisations(policies).each do |organisation|
  org_policies = top_3_policy_results(organisation)

  org_policies.each.with_index do |policy, index|
    FeaturedPolicy.create(
      organisation: organisation,
      policy_content_id: policy_content_id(policies, policy.link),
      ordering: index
    )
  end
end
