require 'test_helper'

class Admin::PoliciesControllerTest < ActionController::TestCase
  class NationalApplicabilityTest < ActionController::TestCase
    tests Admin::PoliciesController

    setup do
      login_as :policy_writer
    end

    include TestsForNationalApplicability

    private

    def document_class
      Policy
    end
  end
end
