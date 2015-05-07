require 'gds_api/test_helpers/content_register'

module ContentRegisterHelpers
  include GdsApi::TestHelpers::ContentRegister

  def stub_content_register_policies
    stub_content_register_entries("policy", [policy_1, policy_2, policy_relevant_to_local_government])
  end

  def content_register_has_policies(policy_titles)
    policies = policy_titles.map { |title|
      {
        "content_id" => SecureRandom.uuid,
        "format" => "policy",
        "title" => title,
        "base_path" => "/government/policies/#{title.parameterize}",
      }
    }

    stub_content_register_entries("policy", policies)
    policies
  end

  def policy_1
    @policy_1 ||= {
        "content_id" => SecureRandom.uuid,
        "format" => "policy",
        "title" => "Policy 1",
        "base_path" => "/government/policies/policy-1",
      }
  end

  def policy_2
    @policy_2 ||= {
        "content_id" => SecureRandom.uuid,
        "format" => "policy",
        "title" => "Policy 2",
        "base_path" => "/government/policies/policy-2",
      }
  end

  def policy_3
    @policy_3 ||= {
        "content_id" => SecureRandom.uuid,
        "format" => "policy",
        "title" => "Policy 3",
        "base_path" => "/government/policies/policy-3",
      }
  end

  def policy_4
    @policy_4 ||= {
        "content_id" => SecureRandom.uuid,
        "format" => "policy",
        "title" => "Policy 4",
        "base_path" => "/government/policies/policy-4",
      }
  end

  def policy_relevant_to_local_government
    @policy_relevant_to_local_government ||= {
      "content_id" => "5d37821b-7631-11e4-a3cb-005056011aef",
      "format" => "policy",
      "title" => "2012 olympic and paralympic legacy",
      "base_path" => "/government/policies/2012-olympic-and-paralympic-legacy",
    }
  end
end
