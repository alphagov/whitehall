module AdminEditionRolesBehaviour
  extend ActiveSupport::Concern

  module ClassMethods
    def should_allow_association_between_roles_and(document_type)
      edition_class = class_for(document_type)

      view_test "new displays document form with roles field" do
        get :new

        assert_select "form#new_edition" do
          assert_select "label[for=edition_roles]", text: "Roles"
          assert_select "#edition_roles" do |elements|
            assert_equal 1, elements.length
          end
        end
      end

      test "creating should create a new document with roles" do
        role1 = create(:role)
        role2 = create(:role)
        attributes = controller_attributes_for(document_type)

        post :create,
             params: {
               edition: attributes.merge(
                 role_ids: [role1.id, role2.id],
               ),
             }

        assert document = edition_class.last
        assert_equal [role1, role2], document.roles
      end

      view_test "edit displays document form with roles field" do
        edition = create(document_type) # rubocop:disable Rails/SaveBang
        get :edit, params: { id: edition }

        assert_select "form#edit_edition" do
          assert_select "label[for=edition_roles]", text: "Roles"

          assert_select "#edition_roles" do |elements|
            assert_equal 1, elements.length
          end
        end
      end

      test "updating should save modified document attributes with roles" do
        role1 = create(:role)
        role2 = create(:role)
        document = create(document_type, roles: [role2])

        put :update,
            params: { id: document,
                      edition: {
                        role_ids: [role1.id],
                      } }

        document = document.reload
        assert_equal [role1], document.roles
      end

      view_test "updating a stale document should render edit page with conflicting document and its roles" do
        document = create(document_type) # rubocop:disable Rails/SaveBang
        lock_version = document.lock_version
        document.touch

        put :update, params: { id: document, edition: { lock_version: } }

        assert_select ".conflict" do
          assert_select "h2", "Roles"
        end
      end
    end
  end
end
