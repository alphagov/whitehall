require 'test_helper'

class Edition::RoleAppointmentsTest < ActiveSupport::TestCase
  test "re-drafting an edition with role appointments copies the appointments" do
    appointments = [
      create(:role_appointment),
      create(:role_appointment),
    ]
    published = create(:published_news_article, role_appointments: appointments)
    assert_equal appointments, published.create_draft(create(:user)).role_appointments
  end
end
