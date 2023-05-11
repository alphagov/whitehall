require "test_helper"

class Admin::PublicationsControllerTest < ActionController::TestCase
  class LegacyNationalApplicabilityTest < ActionController::TestCase
    tests Admin::PublicationsController

    setup do
      login_as :writer
    end

    include LegacyTestsForNationalApplicability

  private

    def edition_class
      Publication
    end
  end
end
