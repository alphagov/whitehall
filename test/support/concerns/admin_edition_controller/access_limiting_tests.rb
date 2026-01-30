module AdminEditionController
  module AccessLimitingTests
    extend ActiveSupport::Concern

    included do
      test "create should record the access_limited flag" do
        organisation = create(:organisation)
        controller.current_user.organisation = organisation
        controller.current_user.save!

        post :create,
             params: {
               edition: controller_attributes_for(edition_type).merge(
                 first_published_at: Date.parse("2010-10-21"),
                 access_limited: "1",
                 lead_organisation_ids: [organisation.id],
               ),
             }

        created_publication = edition_class.last
        assert_not created_publication.nil?
        assert created_publication.access_limited?
      end

      view_test "edit displays persisted access_limited flag" do
        publication = create(edition_type, access_limited: false)

        get :edit, params: { id: publication }

        assert_select "form#edit_edition" do
          assert_select "input[name='edition[access_limited]'][type=checkbox]"
          assert_select "input[name='edition[access_limited]'][type=checkbox][checked=checked]", count: 0
        end
      end

      test "update records new value of access_limited flag" do
        controller.current_user.organisation = create(:organisation)
        controller.current_user.save!
        publication = create(edition_type, access_limited: false, organisations: [controller.current_user.organisation])

        put :update,
            params: {
              id: publication,
              edition: {
                access_limited: "1",
              },
            }

        assert publication.reload.access_limited?
      end

      view_test "access limiting document fails if user does not belong to one of the tagged organisations" do
        controller.current_user.organisation = create(:organisation)
        controller.current_user.save!
        organisation = create(:organisation)
        edition = create(edition_type, access_limited: false, organisations: [organisation])

        put :update,
            params: {
              id: edition,
              edition: {
                access_limited: "1",
              },
            }

        assert_not edition.reload.access_limited?
        assert_select "div[role='alert']", text: "Access can only be limited by users belonging to an organisation tagged to the document"
      end
    end

  private

    def edition_class
      @edition_class ||= edition_type.to_s.classify.constantize
    end
  end
end
