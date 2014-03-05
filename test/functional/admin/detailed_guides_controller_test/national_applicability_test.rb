require 'test_helper'

class Admin::DetailedGuidesControllerTest < ActionController::TestCase
  class NationalApplicabilityTest < ActionController::TestCase
    tests Admin::DetailedGuidesController

    setup do
      login_as create(:policy_writer, organisation: create(:organisation))
    end

    include TestsForNationalApplicability

    private

    def edition_class
      DetailedGuide
    end

    def attributes_for_edition(attributes = {})
      super.except(:primary_mainstream_category).reverse_merge(
        primary_mainstream_category_id: create(:mainstream_category).id
      )
    end
  end
end
