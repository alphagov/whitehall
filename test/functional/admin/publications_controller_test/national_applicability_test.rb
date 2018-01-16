require 'test_helper'

class Admin::PublicationsControllerTest < ActionController::TestCase
  class NationalApplicabilityTest < ActionController::TestCase
    tests Admin::PublicationsController

    setup do
      login_as :writer
    end

    include TestsForNationalApplicability

  private

    def edition_class
      Publication
    end
  end
end
