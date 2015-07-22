require 'test_helper'

class Admin::DetailedGuidesControllerTest < ActionController::TestCase
  class NationalApplicabilityTest < ActionController::TestCase
    tests Admin::DetailedGuidesController

    setup do
      login_as create(:writer, organisation: create(:organisation))
    end

    include TestsForNationalApplicability

    private

    def edition_class
      DetailedGuide
    end
  end
end
