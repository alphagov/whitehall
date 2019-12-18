require "gds_api/test_helpers/search"
require "gds_api/test_helpers/publishing_api_v2"

module PolicyTaggingHelpers
  include GdsApi::TestHelpers::Search

  def policy_relevant_to_local_government
    @policy_relevant_to_local_government ||= {
      "content_id" => "5d37821b-7631-11e4-a3cb-005056011aef",
      "format" => "policy",
      "title" => "2012 olympic and paralympic legacy",
      "base_path" => "/government/policies/2012-olympic-and-paralympic-legacy",
      "links" => {},
    }
  end

  def policy_area_1
    @policy_area_1 ||= {
      "content_id" => SecureRandom.uuid,
      "format" => "policy",
      "title" => "Parent Policy 1",
      "base_path" => "/government/policies/policy-area-1",
      "links" => {},
    }
  end

  def policy_area_2
    @policy_area_2 ||= {
      "content_id" => SecureRandom.uuid,
      "format" => "policy",
      "title" => "Parent Policy 2",
      "base_path" => "/government/policies/policy-area-2",
      "links" => {},
    }
  end

  def policy_area_3
    @policy_area_3 ||= {
      "content_id" => SecureRandom.uuid,
      "format" => "policy",
      "title" => "Parent Policy 3",
      "base_path" => "/government/policies/policy-area-3",
      "links" => {},
    }
  end

  def policy_area_4
    @policy_area_4 ||= {
      "content_id" => SecureRandom.uuid,
      "format" => "policy",
      "title" => "Parent Policy 4",
      "base_path" => "/government/policies/parent-policy-4",
      "links" => {},
      }
  end
end
