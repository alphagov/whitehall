module AdminEditionWorldLocationsBehaviour
  extend ActiveSupport::Concern

  module ClassMethods
    def should_allow_association_between_world_locations_and(document_type)
      edition_class = edition_class_for(document_type)

      test "new displays document form with world locations field" do
        get :new

        assert_select "form#edition_new" do
          assert_select "select[name*='edition[world_location_ids]']"
        end
      end

      test "creating should create a new document with world locations" do
        country = create(:country)
        overseas_territory = create(:overseas_territory)
        attributes = controller_attributes_for(document_type)

        post :create, edition: attributes.merge(
          world_location_ids: [country.id, overseas_territory.id]
        )

        assert document = edition_class.last
        assert_equal [country, overseas_territory], document.world_locations
      end

      test "updating should save modified document attributes with world locations" do
        country = create(:country)
        overseas_territory = create(:overseas_territory)
        document = create(document_type, world_locations: [overseas_territory])

        put :update, id: document, edition: {
          world_location_ids: [country.id]
        }

        document = document.reload
        assert_equal [country], document.world_locations
      end

      test "updating should remove all world locations if none in params" do
        world_location = create(:world_location)

        document = create(document_type, world_locations: [world_location])

        put :update, id: document, edition: {}

        document.reload
        assert_equal [], document.world_locations
      end

      test "updating a stale document should render edit page with conflicting document and its world locations" do
        document = create(document_type)
        lock_version = document.lock_version
        document.touch

        put :update, id: document, edition: controller_attributes_for_instance(document, lock_version: lock_version)

        assert_select ".document.conflict" do
          assert_select "h1", "World locations"
        end
      end

      test "should display the world locations to which the document relates" do
        country = create(:country)
        overseas_territory = create(:overseas_territory)
        document = create(document_type, world_locations: [overseas_territory, country])

        get :show, id: document

        assert_select_object(country)
        assert_select_object(overseas_territory)
      end

      test "should indicate that the document does not relate to any world location" do
        document = create(document_type, world_locations: [])

        get :show, id: document

        assert_select "p", "This document isn't assigned to any world locations."
      end
    end
  end
end