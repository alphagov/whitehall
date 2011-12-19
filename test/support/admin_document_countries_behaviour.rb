module AdminDocumentCountriesBehaviour
  extend ActiveSupport::Concern

  module ClassMethods
    def should_allow_association_between_countries_and(document_type)
      test "new displays document form with countries field" do
        get :new

        assert_select "form#document_new" do
          assert_select "select[name*='document[country_ids]']"
        end
      end
    end
  end
end