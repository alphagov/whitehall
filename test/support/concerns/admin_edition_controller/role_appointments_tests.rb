module AdminEditionController::RoleAppointmentsTests
  extend ActiveSupport::Concern

  included do
    def edition_type_class
      self.class.class_for(edition_type)
    end

    view_test "new should display edition role appointments field" do
      get :new

      assert_select "form#new_edition" do
        assert_select "label[for=edition_role_appointment_ids]", text: "Ministers"

        assert_select "#edition_role_appointment_ids" do |elements|
          assert_equal 1, elements.length
        end
      end
    end

    test "create should associate role appointments with edition" do
      first_appointment = create(:role_appointment)
      second_appointment = create(:role_appointment)
      attributes = controller_attributes_for(edition_type)

      post :create,
           params: {
             edition: attributes.merge(
               role_appointment_ids: [first_appointment.id, second_appointment.id],
             ),
           }

      edition = edition_type_class.last
      assert_equal [first_appointment, second_appointment], edition.role_appointments
    end

    view_test "edit should display edition role appointments field" do
      edition = create(edition_type) # rubocop:disable Rails/SaveBang

      get :edit, params: { id: edition }

      assert_select "form#edit_edition" do
        assert_select "select[name*='edition[role_appointment_ids]']"
      end
    end

    test "update should associate role appointments with editions" do
      first_appointment = create(:role_appointment)
      second_appointment = create(:role_appointment)

      edition = create(edition_type, role_appointments: [first_appointment])

      put :update,
          params: {
            id: edition,
            edition: {
              role_appointment_ids: [second_appointment.id],
            },
          }

      edition.reload
      assert_equal [second_appointment], edition.role_appointments
    end
  end
end
