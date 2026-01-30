module AdminEditionController
  module WorldwideOrganisationsTests
    extend ActiveSupport::Concern

    included do
      view_test "new should display worldwide organisations field" do
        get :new

        assert_select "form#new_edition" do
          assert_select("label[for=edition_worldwide_organisation_document_ids]", text: "Worldwide organisations")

          assert_select "#edition_worldwide_organisation_document_ids" do |elements|
            assert_equal 1, elements.length
          end
        end
      end

      view_test "edit should display worldwide organisations field" do
        edition = create!(edition_type)
        get :edit, params: { id: edition }

        assert_select "form#edit_edition" do
          assert_select("label[for=edition_worldwide_organisation_document_ids]", text: "Worldwide organisations")

          assert_select "#edition_worldwide_organisation_document_ids" do |elements|
            assert_equal 1, elements.length
          end
        end
      end

      test "create should associate worldwide organisations with the edition" do
        first_worldwide_organisation = create(:worldwide_organisation, document: create(:document))
        second_worldwide_organisation = create(:worldwide_organisation, document: create(:document))
        attributes = controller_attributes_for(edition_type)

        post :create,
             params: {
               edition: attributes.merge(
                 worldwide_organisation_document_ids: [first_worldwide_organisation.document.id, second_worldwide_organisation.document.id],
               ),
             }

        edition = edition_class.last!
        assert_equal [first_worldwide_organisation, second_worldwide_organisation], edition.worldwide_organisations
      end
    end

    def edition_class
      @edition_class ||= edition_type.to_s.classify.constantize
    end
  end
end
