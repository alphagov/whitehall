require 'test_helper'

class Admin::NewsArticlesControllerTest < ActionController::TestCase
  class CountriesTest < ActionController::TestCase
    tests Admin::NewsArticlesController

    setup do
      login_as :policy_writer
    end

    include TestsForCountries

    private

    def document_class
      NewsArticle
    end
  end
end
