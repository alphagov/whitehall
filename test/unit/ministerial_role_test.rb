require "test_helper"

class MinisterialRoleTest < ActiveSupport::TestCase
  test "should set a slug from the ministerial role name" do
    role = create(:ministerial_role, name: "Prime Minister, Cabinet Office")
    assert_equal "prime-minister-cabinet-office", role.slug
  end

  test "should not change the slug when the name is changed" do
    role = create(:ministerial_role, name: "Prime Minister, Cabinet Office")
    role.update!(name: "Prime Minister")
    assert_equal "prime-minister-cabinet-office", role.slug
  end

  test "should be able to get news_articles associated with a role" do
    editions = [create(:published_publication), create(:published_news_article)]
    ministerial_role = create(:ministerial_role)
    create(:role_appointment, role: ministerial_role, editions: editions)
    assert_equal editions[1..1], ministerial_role.news_articles
  end

  test "should be able to get published news_articles associated with the role" do
    editions = [create(:draft_news_article), create(:published_news_article), create(:news_article, :withdrawn)]
    ministerial_role = create(:ministerial_role)
    create(:role_appointment, role: ministerial_role, editions: editions)
    assert_equal editions[1..1], ministerial_role.published_news_articles
  end

  test "should only ever get a news article once" do
    ministerial_role = create(:ministerial_role)
    appointment1 = create(:role_appointment, role: ministerial_role, started_at: 2.days.ago, ended_at: 1.day.ago)
    appointment2 = create(:role_appointment, role: ministerial_role)
    editions = [create(:published_news_article, role_appointments: [appointment1, appointment2])]
    assert_equal editions, ministerial_role.news_articles
  end

  test "should be able to get published speeches associated with the current appointee" do
    appointment = create(
      :ministerial_role_appointment,
      started_at: 1.day.ago,
      ended_at: nil,
    )
    create(:published_speech, role_appointment: appointment)
    create(:speech, :withdrawn, role_appointment: appointment)
    create(:draft_speech, role_appointment: appointment)

    assert appointment.role.published_speeches.all?(&:published?)
    assert_equal 1, appointment.role.published_speeches.count
  end

  test "published_speeches should not return speeches from previous appointees" do
    appointment = create(
      :ministerial_role_appointment,
      started_at: 2.days.ago,
      ended_at: 1.day.ago,
    )
    create(:published_speech, role_appointment: appointment)

    assert_equal 1, appointment.role.published_speeches.count
  end

  test "should not be destroyable when it is responsible for editions" do
    ministerial_role = create(:ministerial_role)
    create(:role_appointment, role: ministerial_role, editions: [create(:edition)])
    assert_not ministerial_role.destroyable?
    assert_equal false, ministerial_role.destroy
  end

  test "should be destroyable when it has no appointments, organisations or editions" do
    ministerial_role = create(:ministerial_role_without_organisation, role_appointments: [], organisations: [])
    assert ministerial_role.destroyable?
    assert ministerial_role.destroy
  end

  test "can never be a permanent secretary" do
    ministerial_role = build(:ministerial_role)
    assert_not ministerial_role.permanent_secretary?
  end

  test "can never be a chief of the defence staff" do
    ministerial_role = build(:ministerial_role)
    assert_not ministerial_role.chief_of_the_defence_staff?
  end

  test "#current_person_name should return the role name when vacant" do
    role = create(:ministerial_role, name: "Minister of Importance", people: [])
    assert_equal "Minister of Importance", role.current_person_name
  end
end
