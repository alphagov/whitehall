require 'test_helper'

class Admin::PublicationsControllerTest < ActionController::TestCase
  class NationalApplicabilityTest < ActionController::TestCase
    tests Admin::PublicationsController

    setup do
      login_as "Somebody"
    end

    include TestsForNationalApplicability

    private

    def document_class
      Publication
    end
  end
end
