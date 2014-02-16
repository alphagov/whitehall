require "test_helper"

class MinisterialRolesControllerTest < ActionController::TestCase
  include FeedHelper

  should_be_a_public_facing_controller
  should_show_published_documents_associated_with :ministerial_role, :policies

  test "shows cabinet roles in correct order" do
    nick_clegg = create(:person, forename: 'Nick', surname: 'Clegg')
    jeremy_hunt = create(:person, forename: 'Jeremy', surname: 'Hunt')
    edward_garnier = create(:person, forename: 'Edward', surname: 'Garnier')
    david_cameron = create(:person, forename: 'David', surname: 'Cameron')
    philip_hammond = create(:person, forename: 'Philip', surname: 'Hammond')
    davey_jones = create(:person, forename: 'Davey', surname: 'Jones')

    deputy_prime_minister = create(:ministerial_role, name: 'Deputy Prime Minister', cabinet_member: true, seniority: 1)
    culture_minister = create(:ministerial_role, name: 'Secretary of State for Culture', cabinet_member: true)
    solicitor_general = create(:ministerial_role, name: 'Solicitor General', cabinet_member: false)
    prime_minister = create(:ministerial_role, name: 'Prime Minister', cabinet_member: true, seniority: 0)
    defence_minister = create(:ministerial_role, name: 'Secretary of State for Defence', cabinet_member: true)
    first_sec_of_state = create(:ministerial_role, name: 'First Secretary of State', cabinet_member: true, seniority: 2)

    create(:ministerial_role_appointment, role: deputy_prime_minister, person: nick_clegg)
    create(:ministerial_role_appointment, role: culture_minister, person: jeremy_hunt)
    create(:ministerial_role_appointment, role: solicitor_general, person: edward_garnier)
    create(:ministerial_role_appointment, role: prime_minister, person: david_cameron)
    create(:ministerial_role_appointment, role: defence_minister, person: philip_hammond)
    create(:ministerial_role_appointment, role: first_sec_of_state, person: davey_jones)

    get :index

    assert_equal [prime_minister, deputy_prime_minister, first_sec_of_state, defence_minister, culture_minister], assigns(:cabinet_ministerial_roles).map { |person, role| role.first.model }
  end

  test "shows ministers by organisation in the cms-defined order" do
    organisation = create(:ministerial_department)
    person_2 = create(:person, forename: 'Jeremy', surname: 'Hunt')
    person_1 = create(:person, forename: 'Nick', surname: 'Clegg')
    person_3 = create(:person, forename: 'George', surname: 'Foreman')
    person_4 = create(:person, forename: 'Brian', surname: 'Smith')

    role_2 = create(:ministerial_role, name: 'Non-Executive Director', cabinet_member: false, organisations: [organisation], seniority: 1)
    role_1 = create(:ministerial_role, name: 'Prime Minister', cabinet_member: true, organisations: [organisation], seniority: 0)
    role_3 = create(:board_member_role, name: 'Chief Griller', organisations: [organisation], seniority: 3)
    role_4 = create(:ministerial_role, name: 'First Secretary of State', cabinet_member: true, organisations: [organisation], seniority: 2)

    organisation.organisation_roles.find_by_role_id(role_2.id).update_column(:ordering, 3)
    organisation.organisation_roles.find_by_role_id(role_1.id).update_column(:ordering, 2)
    organisation.organisation_roles.find_by_role_id(role_4.id).update_column(:ordering, 1)

    appointment_2 = create(:ministerial_role_appointment, role: role_2, person: person_2)
    appointment_1 = create(:ministerial_role_appointment, role: role_1, person: person_1)
    appointment_3 = create(:board_member_role_appointment, role: role_3, person: person_3)
    appointment_4 = create(:ministerial_role_appointment, role: role_4, person: person_4)

    get :index

    expected_results = [[organisation, RolesPresenter.new([role_4, role_1, role_2], @controller.view_context)]]
    assert_equal expected_results, assigns(:ministers_by_organisation)
  end

  test "shows ministers who also attend cabinet separately" do
    organisation = create(:ministerial_department)
    person_1 = create(:person, forename: 'Nick', surname: 'Clegg')
    person_2 = create(:person, forename: 'Jeremy', surname: 'Hunt')
    person_3 = create(:person, forename: 'Geroge', surname: 'Foreman')

    role_1 = create(:ministerial_role, name: 'Prime Minister', cabinet_member: true, organisations: [organisation])
    role_2 = create(:ministerial_role, name: 'Non-Executive Director', cabinet_member: false, organisations: [organisation])
    role_3 = create(:ministerial_role, name: 'Chief Whip and Parliamentary Secretary to the Treasury', organisations: [organisation], whip_organisation_id: 1, attends_cabinet_type_id: 1)

    appointment_1 = create(:ministerial_role_appointment, role: role_1, person: person_1)
    appointment_2 = create(:ministerial_role_appointment, role: role_2, person: person_2)
    appointment_3 = create(:ministerial_role_appointment, role: role_3, person: person_3)

    get :index

    assert_equal [role_3], assigns(:also_attends_cabinet).map { |person, role| role.first.model }
  end


  test "shows whips separately" do
    organisation = create(:ministerial_department)
    person_1 = create(:person, forename: 'Nick', surname: 'Clegg')
    person_2 = create(:person, forename: 'Jeremy', surname: 'Hunt')
    person_3 = create(:person, forename: 'Geroge', surname: 'Foreman')

    role_1 = create(:ministerial_role, name: 'Prime Minister', cabinet_member: true, organisations: [organisation])
    role_2 = create(:ministerial_role, name: 'Non-Executive Director', cabinet_member: false, organisations: [organisation])
    role_3 = create(:ministerial_role, name: 'Chief Whip and Parliamentary Secretary to the Treasury', organisations: [organisation], whip_organisation_id: 1)

    appointment_1 = create(:ministerial_role_appointment, role: role_1, person: person_1)
    appointment_2 = create(:ministerial_role_appointment, role: role_2, person: person_2)
    appointment_3 = create(:ministerial_role_appointment, role: role_3, person: person_3)

    get :index

    whips = [[Whitehall::WhipOrganisation.find_by_id(1), RolesPresenter.new([role_3], @controller.view_context)]]

    assert_equal whips, assigns(:whips_by_organisation)
  end

  test 'orders whips by organisation sort order' do
    organisation = create(:ministerial_department)

    person_1 = create(:person)
    person_2 = create(:person)
    person_3 = create(:person)
    person_4 = create(:person)
    person_5 = create(:person)

    role_1 = create(:ministerial_role, organisations: [organisation], whip_organisation_id: 1)
    role_2 = create(:ministerial_role, organisations: [organisation], whip_organisation_id: 2)
    role_3 = create(:ministerial_role, organisations: [organisation], whip_organisation_id: 3)
    role_4 = create(:ministerial_role, organisations: [organisation], whip_organisation_id: 4)
    role_5 = create(:ministerial_role, organisations: [organisation], whip_organisation_id: 5)

    appointment_1 = create(:ministerial_role_appointment, role: role_1, person: person_1)
    appointment_2 = create(:ministerial_role_appointment, role: role_2, person: person_2)
    appointment_3 = create(:ministerial_role_appointment, role: role_3, person: person_3)
    appointment_4 = create(:ministerial_role_appointment, role: role_4, person: person_4)
    appointment_5 = create(:ministerial_role_appointment, role: role_5, person: person_5)

    get :index

    whips = [
      [Whitehall::WhipOrganisation.find_by_id(1), RolesPresenter.new([role_1], @controller.view_context)],
      [Whitehall::WhipOrganisation.find_by_id(3), RolesPresenter.new([role_3], @controller.view_context)],
      [Whitehall::WhipOrganisation.find_by_id(4), RolesPresenter.new([role_4], @controller.view_context)],
      [Whitehall::WhipOrganisation.find_by_id(2), RolesPresenter.new([role_2], @controller.view_context)],
      [Whitehall::WhipOrganisation.find_by_id(5), RolesPresenter.new([role_5], @controller.view_context)]
    ]
    assert_equal whips, assigns(:whips_by_organisation)
  end

  test 'index loads ministerial-reshuffle snippet' do
    snippet = Snippet.create(key: "ministerial-reshuffle", body: "<p>The reshuffle is happening today. </p>")

    get :index

    assert_equal "<p>The reshuffle is happening today. </p>", assigns[:snippet]
    assert assigns[:snippet].html_safe?
  end

  view_test "shows the cabinet minister's name and role" do
    person = create(:person, forename: "John", surname: "Doe", image: image_fixture_file)
    ministerial_role = create(:ministerial_role, name: "Prime Minister", cabinet_member: true)
    create(:role_appointment, person: person, role: ministerial_role)

    get :index

    assert_select_object(person) do
      assert_select ".current-appointee", text: "John Doe"
      assert_minister_role_links_to_their_role(ministerial_role)
    end
  end

  view_test "shows the non-cabinet minister's name and role" do
    person = create(:person, forename: "John", surname: "Doe")
    ministerial_role = create(:ministerial_role, name: "Prime Minister", cabinet_member: false)
    create(:role_appointment, person: person, role: ministerial_role)

    get :index

    assert_select_prefix_object(person, 'by-organisation') do
      assert_select "a[href=?]", person_path(person), text: "John Doe"
      assert_minister_role_links_to_their_role(ministerial_role)
    end
  end

  view_test "shows only published news and speeches associated with ministerial role" do
    ministerial_role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: ministerial_role)
    published_speech = create(:published_speech, role_appointment: role_appointment)
    draft_speech = create(:draft_speech, role_appointment: role_appointment)
    published_news_article = create(:published_news_article, role_appointments: [role_appointment])
    draft_news_article = create(:draft_news_article, role_appointments: [role_appointment])

    get :show, id: ministerial_role

    assert_select_object(published_speech)
    refute_select_object(draft_speech)
    assert_select_object(published_news_article)
    refute_select_object(draft_news_article)
  end

  view_test "shows only news and speeches associated with ministerial role" do
    ministerial_role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: ministerial_role)
    published_speech = create(:published_speech, role_appointment: role_appointment)
    published_news_article = create(:published_news_article, role_appointments: [role_appointment])

    another_ministerial_role = create(:ministerial_role)
    another_role_appointment = create(:role_appointment, role: another_ministerial_role)
    another_published_speech = create(:published_speech, role_appointment: another_role_appointment)
    another_published_news_article = create(:published_news_article, role_appointments: [another_role_appointment])

    get :show, id: ministerial_role

    assert_select ".announcements" do
      assert_select_object(published_speech)
      refute_select_object(another_published_speech)
      assert_select_object(published_news_article)
      refute_select_object(another_published_news_article)
    end
  end

  view_test 'show has atom feed autodiscovery link' do
    ministerial_role = create(:ministerial_role)
    get :show, id: ministerial_role
    assert_select_autodiscovery_link atom_feed_url_for(ministerial_role)
  end

  view_test "show generates an atom feed of news and speeches associated with the ministerial role" do
    ministerial_role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: ministerial_role)
    expected_entries = [
      create(:published_news_article, role_appointments: [role_appointment], first_published_at: 1.day.ago),
      create(:published_speech, role_appointment: role_appointment, delivered_on: 2.days.ago.to_date)
    ]

    get :show, format: :atom, id: ministerial_role

    assert_select_atom_feed do
      assert_select_atom_entries(expected_entries)
    end
  end

  view_test "should not display an empty published speeches section" do
    ministerial_role = create(:ministerial_role)

    get :show, id: ministerial_role

    refute_select ".news_and_speeches"
  end

  view_test "show lists previous appointments for non-historic roles" do
    role = create(:ministerial_role)
    first_appointment = create(:role_appointment, role: role, started_at: 9.years.ago, ended_at: 4.years.ago)
    second_appointment = create(:role_appointment, role: role, started_at: 4.years.ago, ended_at: 5.days.ago)
    get :show, id: role


    assert_select ".previous-roles" do
      assert_select_object first_appointment do
        assert_select "a[href=#{person_path(first_appointment.person)}]", text: first_appointment.person.name
      end
      assert_select_object second_appointment do
        assert_select "a[href=#{person_path(second_appointment.person)}]", text: second_appointment.person.name
      end
    end
  end

  view_test "show links to historical appointments when the role is historic" do
    historic_role = create(:historic_role, name: 'Prime Minister')
    get :show, id: historic_role

    assert_select ".previous-roles" do
      assert_select "a[href=#{historic_appointments_path('past-prime-ministers')}]", text: "past #{historic_role.name.pluralize}"
    end
  end

  test "shows only latest role appointments" do
    person = create(:person, forename: "John", surname: "Doe")
    organisation = create(:ministerial_department)
    ministerial_role = create(:ministerial_role, name: "Prime Minister", cabinet_member: true, organisations: [organisation])
    old_role = create(:ministerial_role, name: "Pharoah", cabinet_member: true, organisations: [organisation])
    appointment_1 = create(:role_appointment, person: person, role: ministerial_role)
    appointment_2 = create(:role_appointment, person: person, role: old_role, started_at: 10.days.ago, ended_at: 5.days.ago)

    get :index

    expected_results = [[organisation, RolesPresenter.new([ministerial_role], @controller.view_context)]]
    assert_equal expected_results, assigns(:ministers_by_organisation)
  end

  private

  def assert_minister_photo_links_to_the_person(person)
    assert_select ".image_holder a[href='#{person_path(person)}'] img[src='#{person.image_url}']"
  end

  def assert_minister_role_links_to_their_role(role)
    assert_select ".role a[href='#{ministerial_role_path(role)}']", text: role.name
  end
end
