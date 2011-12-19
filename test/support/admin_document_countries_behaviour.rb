module AdminDocumentCountriesBehaviour
  extend ActiveSupport::Concern

  module ClassMethods
    def should_allow_association_between_countries_and(document_type)
      document_class = document_class_for(document_type)

      test "new displays document form with countries field" do
        get :new

        assert_select "form#document_new" do
          assert_select "select[name*='document[country_ids]']"
        end
      end

      test "creating should create a new document with countries" do
        first_country = create(:country)
        second_country = create(:country)
        attributes = controller_attributes_for(document_type)

        post :create, document: attributes.merge(
          country_ids: [first_country.id, second_country.id]
        )

        assert document = document_class.last
        assert_equal [first_country, second_country], document.countries
      end

      test "updating should save modified document attributes with countries" do
        first_country = create(:country)
        second_country = create(:country)
        document = create(document_type, countries: [first_country])

        put :update, id: document, document: {
          country_ids: [second_country.id]
        }

        document = document.reload
        assert_equal [second_country], document.countries
      end

      test "updating should remove all countries if none in params" do
        country = create(:country)

        document = create(document_type, countries: [country])

        put :update, id: document, document: {}

        document.reload
        assert_equal [], document.countries
      end

      test "updating a stale document should render edit page with conflicting document and its countries" do
        document = create(document_type)
        lock_version = document.lock_version
        document.touch

        put :update, id: document, document: document.attributes.merge(lock_version: lock_version)

        assert_select ".document.conflict" do
          assert_select "h1", "Countries"
        end
      end

      test "should display the countries to which the document relates" do
        first_country = create(:country)
        second_country = create(:country)
        document = create(document_type, countries: [first_country, second_country])

        get :show, id: document

        assert_select_object(first_country)
        assert_select_object(second_country)
      end

      test "should indicate that the document does not relate to any country" do
        document = create(document_type, countries: [])

        get :show, id: document

        assert_select "p", "This document isn't assigned to any countries."
      end
    end
  end
end