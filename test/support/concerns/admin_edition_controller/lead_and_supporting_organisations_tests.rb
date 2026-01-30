module AdminEditionController
  module LeadAndSupportingOrganisationsTests
    extend ActiveSupport::Concern

    included do
      def edition_type_class
        class_for(edition_type)
      end

      view_test "new should display edition organisations fields" do
        get :new

        assert_select "form#new_edition" do
          (1..4).each do |i|
            assert_select "label[for=edition_lead_organisation_ids_#{i}]", text: "Lead organisation #{i}"

            assert_select("#edition_lead_organisation_ids_#{i}") do |elements|
              assert_equal 1, elements.length
            end
          end
          refute_select "#edition_lead_organisation_ids_5"
          assert_select("#edition_supporting_organisation_ids")
        end
      end

      test "new should set first lead organisation to users organisation" do
        editors_org = create(:organisation)
        @user = login_as create(:departmental_editor, organisation: editors_org)
        get :new

        assert_equal assigns(:edition).edition_organisations.first.organisation, editors_org
        assert_equal assigns(:edition).edition_organisations.first.lead, true
        assert_equal assigns(:edition).edition_organisations.first.lead_ordering, 0
      end

      test "create should associate organisations with edition" do
        first_organisation = create(:organisation)
        second_organisation = create(:organisation)
        attributes = controller_attributes_for(edition_type)

        post :create,
             params: {
               edition: attributes.merge(
                 lead_organisation_ids: [second_organisation.id, first_organisation.id],
               ),
             }

        edition = edition_type_class.last
        assert_equal [second_organisation, first_organisation], edition.lead_organisations
      end

      view_test "edit should display edition organisations field" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang

        get :edit, params: { id: edition }

        assert_select "form#edit_edition" do
          (1..4).each do |i|
            assert_select "label[for=edition_lead_organisation_ids_#{i}]", text: "Lead organisation #{i}"

            assert_select("#edition_lead_organisation_ids_#{i}") do |elements|
              assert_equal 1, elements.length
            end
          end
          refute_select "#edition_lead_organisation_ids_5"
          assert_select("#edition_supporting_organisation_ids")
        end
      end

      test "update should associate organisations with editions" do
        first_organisation = create(:organisation)
        second_organisation = create(:organisation)

        edition = create(edition_type, organisations: [first_organisation])

        put :update,
            params: {
              id: edition,
              edition: {
                lead_organisation_ids: [second_organisation.id],
              },
            }

        edition.reload
        assert_equal [second_organisation], edition.lead_organisations
      end

      test "update should allow removal of an organisation" do
        organisation1 = create(:organisation)
        organisation2 = create(:organisation)

        edition = create(edition_type, organisations: [organisation1, organisation2])

        put :update,
            params: {
              id: edition,
              edition: {
                lead_organisation_ids: [organisation2.id],
              },
            }

        edition.reload
        assert_equal [organisation2], edition.lead_organisations
      end

      test "update should allow swapping of an organisation from lead to supporting" do
        organisation1 = create(:organisation)
        organisation2 = create(:organisation)
        organisation3 = create(:organisation)

        edition = build(edition_type)
        edition.lead_organisations = [organisation1, organisation2]
        edition.supporting_organisations = [organisation3]
        edition.save!

        put :update,
            params: {
              id: edition,
              edition: {
                lead_organisation_ids: [organisation2.id, organisation3.id],
                supporting_organisation_ids: [organisation1.id],
              },
            }

        edition.reload
        assert_equal [organisation2, organisation3], edition.lead_organisations
        assert_equal [organisation1], edition.supporting_organisations
      end
    end
  end
end
