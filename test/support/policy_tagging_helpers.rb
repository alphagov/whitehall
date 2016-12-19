require "gds_api/test_helpers/rummager"
require "gds_api/test_helpers/publishing_api_v2"

module PolicyTaggingHelpers
  include GdsApi::TestHelpers::Rummager
  include GdsApi::TestHelpers::PublishingApiV2

  def assert_published_policies_returns_all_tagged_policies(object)
    rummager_has_policies_for_every_type

    all_policy_titles = [
      "Welfare reform",
      "State Pension simplification",
      "State Pension age",
      "Poverty and social justice",
      "Older people",
      "Household energy",
      "Health and safety reform",
      "European funds",
      "Employment",
      "Child maintenance reform",
    ]

    assert_equal all_policy_titles, object.published_policies.collect {|p| p["title"]}
  end

  def stub_publishing_api_policies
    policies = [
      policy_1,
      policy_2,
      policy_3,
      policy_area_1,
      policy_area_2,
      policy_area_3,
      policy_relevant_to_local_government,
    ]

    publishing_api_has_linkables(policies, document_type: "policy")

    policies.each do |policy|
      publishing_api_has_links(
        "content_id" => policy["content_id"],
        "links" => policy["links"],
      )
    end
  end

  def publishing_api_has_policies(policy_titles)
    policies = policy_titles.map { |title|
      {
        "content_id" => SecureRandom.uuid,
        "format" => "policy",
        "title" => title,
        "base_path" => "/government/policies/#{title.parameterize}",
        "links" => {}
      }
    }

    publishing_api_has_linkables(policies, document_type: "policy")

    policies.each do |policy|
      publishing_api_has_links(
        "content_id" => policy["content_id"],
        "links" => policy["links"],
      )
    end

    policies
  end

  def policy_1
    @policy_1 ||= {
        "content_id" => SecureRandom.uuid,
        "format" => "policy",
        "title" => "Policy 1",
        "base_path" => "/government/policies/policy-1",
        "links" => {
          "policy_areas" => [
            policy_area_1["content_id"],
          ]
        }
      }
  end

  def policy_2
    @policy_2 ||= {
        "content_id" => SecureRandom.uuid,
        "format" => "policy",
        "title" => "Policy 2",
        "base_path" => "/government/policies/policy-2",
        "links" => {
          "policy_areas" => [
            policy_area_1["content_id"],
            policy_area_2["content_id"],
          ]
        }
      }
  end

  def policy_3
    @policy_3 ||= {
        "content_id" => SecureRandom.uuid,
        "format" => "policy",
        "title" => "Policy 3",
        "base_path" => "/government/policies/policy-3",
        "links" => {
          "policy_areas" => [
            policy_area_3["content_id"],
          ]
        }
      }
  end

  def policy_4
    @policy_4 ||= {
        "content_id" => SecureRandom.uuid,
        "format" => "policy",
        "title" => "Policy 4",
        "base_path" => "/government/policies/policy-4",
        "links" => {
          "policy_areas" => [
            policy_area_4["content_id"],
          ]
        }
      }
  end

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
