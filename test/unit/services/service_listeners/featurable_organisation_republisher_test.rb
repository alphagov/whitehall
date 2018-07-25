require 'test_helper'

class ServiceListeners::FeaturableOrganisationRepublisherTest < ActiveSupport::TestCase
  setup do
    stub_any_publishing_api_call
  end

  test 'republish organisation to Publishing API' do
    organisation = create(:organisation, :with_feature_list, :with_published_edition)

    feature_list = organisation.feature_lists.sample
    published_edition = organisation.published_editions.sample

    create(:feature, document: published_edition.document, feature_list: feature_list)

    Sidekiq::Testing.inline! do
      expect_publishing(organisation)

      assert ServiceListeners::FeaturableOrganisationRepublisher.new(published_edition).call
    end
  end
end
