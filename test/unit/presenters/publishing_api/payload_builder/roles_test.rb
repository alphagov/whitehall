require "test_helper"

module PublishingApi
  module PayloadBuilder
    class PayloadBuilderRolesTest < ActiveSupport::TestCase
      test "returns empty hash if no roles" do
        edition_with_no_roles = Object.new

        expected_hash = {}

        assert_equal expected_hash, Roles.for(edition_with_no_roles)
      end

      test "returns empty hash if role_appointment is nil" do
        stubbed_edition = stub(role_appointment: nil)

        expected_hash = {}

        assert_equal expected_hash, Roles.for(stubbed_edition)
      end

      test "returns the role if a role_appointment_id exists" do
        role_appointment = create(:role_appointment)
        stubbed_edition = stub(role_appointment: role_appointment)

        expected_hash = { roles: [role_appointment.role.content_id] }

        assert_equal expected_hash, Roles.for(stubbed_edition)
      end

      test "returns empty hash if role_appointments are nil" do
        stubbed_edition = stub(role_appointments: nil)

        expected_hash = {}

        assert_equal expected_hash, Roles.for(stubbed_edition)
      end

      test "returns an array of content_ids from roles in edition_role_appointments" do
        role_appointments = 3.times.map do
          create(:role_appointment)
        end

        stubbed_edition = stub(role_appointments: role_appointments)

        expected_hash = { roles:
          role_appointments.map do |role_appointment|
            role_appointment.role.content_id
          end
        }

        assert_equal expected_hash, Roles.for(stubbed_edition)
      end
    end
  end
end
