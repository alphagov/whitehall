require 'test_helper'

class Admin::SpecialistGuidesControllerTest < ActionController::TestCase
  class NationalApplicabilityTest < ActionController::TestCase
    tests Admin::SpecialistGuidesController

    setup do
      login_as :policy_writer
    end

    include TestsForNationalApplicability

    private

    def edition_class
      SpecialistGuide
    end

    def attributes_for_edition(attributes = {})
      super.except(:primary_mainstream_category).reverse_merge(primary_mainstream_category_id: create(:mainstream_category).id)
    end
  end
end
