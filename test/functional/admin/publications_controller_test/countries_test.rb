require 'test_helper'

class Admin::PublicationsControllerTest < ActionController::TestCase
  class CountriesTest < ActionController::TestCase
    tests Admin::PublicationsController

    setup do
      login_as :policy_writer
    end

    include TestsForCountries

    private

    def document_class
      Publication
    end
  end
end
