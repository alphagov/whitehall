require "test_helper"

class Edition::RoleAppointmentsTest < ActiveSupport::TestCase
  test "re-drafting an edition with role appointments copies the appointments" do
    appointments = [
      create(:role_appointment),
      create(:role_appointment),
    ]
    published = create(:published_news_article, role_appointments: appointments)
    assert_equal appointments, published.create_draft(create(:user)).role_appointments
  end

  test "editions with ministerial role appointments include them in their search info" do
    minister = create(:ministerial_role)
    appointment = create(:role_appointment, role: minister)
    news_article = create(:news_article, role_appointments: [appointment])

    assert_equal [appointment.person.slug], news_article.search_index["people"]
    assert_equal [appointment.role.slug], news_article.search_index["roles"]
  end

  test "editions with non-ministerial role appointments don't include the role in the search info" do
    appointment = create(:role_appointment, role: create(:judge_role))
    news_article = create(:news_article, role_appointments: [appointment])
    assert_equal [], news_article.search_index["roles"]
  end
end
