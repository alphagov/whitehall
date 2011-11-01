require 'test_helper'

class Admin::PoliciesControllerTest < ActionController::TestCase
  class NationalApplicabilityTest < ActionController::TestCase
    tests Admin::PoliciesController

    setup do
      login_as "Somebody"
    end

    include TestsForNationalApplicability

    private

    def document_class
      Policy
    end
  end
end
