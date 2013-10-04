module AdminEditionWorldLocationsBehaviour
  extend ActiveSupport::Concern

  module ClassMethods
    def should_allow_association_between_world_locations_and(document_type)
      edition_class = class_for(document_type)

      view_test "new displays document form with world locations field" do
        get :new

        assert_select "form#new_edition" do
          assert_select "select[name*='edition[world_location_ids]']"
        end
      end

      test "creating should create a new document with world locations" do
        world_location = create(:world_location)
        world_location2 = create(:world_location)
        attributes = controller_attributes_for(document_type)

        post :create, edition: attributes.merge(
          world_location_ids: [world_location.id, world_location2.id]
        )

        assert document = edition_class.last
        assert_equal [world_location, world_location2], document.world_locations
      end

      test "updating should save modified document attributes with world locations" do
        world_location = create(:world_location)
        world_location2 = create(:world_location)
        document = create(document_type, world_locations: [world_location2])

        put :update, id: document, edition: {
          world_location_ids: [world_location.id]
        }

        document = document.reload
        assert_equal [world_location], document.world_locations
      end

      view_test "updating a stale document should render edit page with conflicting document and its world locations" do
        document = create(document_type)
        lock_version = document.lock_version
        document.touch

        put :update, id: document, edition: controller_attributes_for_instance(document, lock_version: lock_version)

        assert_select ".document.conflict" do
          assert_select "h1", "World locations"
        end
      end
    end
  end
end
