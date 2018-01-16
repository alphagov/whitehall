require 'test_helper'

class Admin::ConsultationsControllerTest < ActionController::TestCase
  class NationalApplicabilityTest < ActionController::TestCase
    tests Admin::ConsultationsController

    setup do
      login_as :writer
    end

    include TestsForNationalApplicability

  private

    def edition_class
      Consultation
    end
  end
end
