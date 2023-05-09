require "test_helper"

class Admin::ConsultationsControllerTest < ActionController::TestCase
  class LegacyNationalApplicabilityTest < ActionController::TestCase
    tests Admin::ConsultationsController

    setup do
      login_as :writer
    end

    include LegacyTestsForNationalApplicability

  private

    def edition_class
      Consultation
    end
  end
end
