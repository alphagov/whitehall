require "test_helper"

module PublishingApi
  module PayloadBuilder
    class PayloadBuilderEmphasisedOrganisationsTest < ActiveSupport::TestCase
      def test_uses_emphasised_organisations
        emphasised_organisations = [create(:organisation), create(:organisation)]
        item = stub(lead_organisations: emphasised_organisations)

        assert_equal(
          { emphasised_organisations: emphasised_organisations.map(&:content_id) },
          EmphasisedOrganisations.for(item),
        )
      end
    end
  end
end
