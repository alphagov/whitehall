require "test_helper"

class HomeControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  setup do
    pm_person = create(:person, forename: "Firstname", surname: "Lastname")
    pm_role = create(:ministerial_role_without_organisation, name: "Prime Minister", cabinet_member: true)
    create(:ministerial_role_appointment, role: pm_role, person: pm_person)
  end

  view_test "frontend layout includes header-context element to stop breadcrumbs being inserted" do
    get :how_government_works

    assert_select ".header-context"
  end

  view_test "how government works shows the current prime minister" do
    get :how_government_works

    assert_select ".prime-minister > p:nth-child(5) [href]", "Firstname Lastname"
  end

  view_test "how government works does not fail when there is no prime minister" do
    RoleAppointment.delete_all
    get :how_government_works

    assert_select ".prime-minister > p:nth-child(2) [href]", "Prime Minister"
  end

  view_test "how government works page shows a count of cabinet ministers, other ministers and total ministers" do
    philip_hammond = create(:person, forename: "Philip", surname: "Hammond")
    mark_prisk = create(:person, forename: "Mark", surname: "Prisk")
    michael_gove = create(:person, forename: "Michael", surname: "Gove")

    defence_minister = create(:ministerial_role, name: "Secretary of State for Defence", cabinet_member: true)
    state_for_housing_minister = create(:ministerial_role, name: "Minister of State for Housing", cabinet_member: false)
    education_minister = create(:ministerial_role, name: "Secretary of State for Education", cabinet_member: true)

    create(:ministerial_role_appointment, role: defence_minister, person: philip_hammond)
    create(:ministerial_role_appointment, role: state_for_housing_minister, person: mark_prisk)
    create(:ministerial_role_appointment, role: education_minister, person: michael_gove)

    get :how_government_works

    assert_select ".cabinet-ministers .gem-c-big-number__value", "2"
    assert_select ".other-ministers .gem-c-big-number__value", "1"
    assert_select ".all-ministers .gem-c-big-number__value", "4"
  end

  test "how_government_works should assign @ministerial_department_count to the count of active ministerial departments" do
    create(:ministerial_department)
    create(:ministerial_department)
    create(:ministerial_department, :closed)

    get :how_government_works

    assert_equal 2, assigns[:ministerial_department_count]
  end

  test "how_government_works should assign @non_ministerial_department_count to the count of active non-ministerial departments" do
    create(:non_ministerial_department)
    create(:non_ministerial_department)
    create(:non_ministerial_department, :closed)

    get :how_government_works

    assert_equal 2, assigns[:non_ministerial_department_count]
  end

private

  def create_published_documents
    2.downto(1) do |x|
      create(:published_news_article, first_published_at: x.days.ago + 2.hours)
      create(:published_speech, delivered_on: x.days.ago + 3.hours)
      create(:published_publication, first_published_at: x.days.ago + 4.hours)
      create(:published_consultation, opening_at: x.days.ago + 5.hours)
    end
  end

  def create_draft_documents
    [
      create(:draft_news_article),
      create(:draft_speech),
      create(:draft_consultation),
      create(:draft_publication),
    ]
  end
end
