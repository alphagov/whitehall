require 'gds_api/test_helpers/content_register'

module ContentRegisterHelpers
  include GdsApi::TestHelpers::ContentRegister

  def stub_content_register_policies
    stub_content_register_entries("policy", [policy_1, policy_2])
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
end
