require 'test_helper'

class Admin::InternationalPrioritiesControllerTest < ActionController::TestCase
  class CountriesTest < ActionController::TestCase
    tests Admin::InternationalPrioritiesController

    setup do
      login_as :policy_writer
    end

    include TestsForCountries

    private

    def document_class
      InternationalPriority
    end
  end
end
