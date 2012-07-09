require "test_helper"

class MinisterialRolesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_show_published_documents_associated_with :ministerial_role, :policies
  should_show_published_documents_associated_with :ministerial_role, :publications
  should_show_published_documents_associated_with :ministerial_role, :consultations

  test "shows cabinet roles in correct order" do
    nick_clegg = create(:person, forename: 'Nick', surname: 'Clegg')
    jeremy_hunt = create(:person, forename: 'Jeremy', surname: 'Hunt')
    edward_garnier = create(:person, forename: 'Edward', surname: 'Garnier')
    david_cameron = create(:person, forename: 'David', surname: 'Cameron')
    philip_hammond = create(:person, forename: 'Philip', surname: 'Hammond')
    davey_jones = create(:person, forename: 'Davey', surname: 'Jones')

    deputy_prime_minister = create(:ministerial_role, name: 'Deputy Prime Minister', cabinet_member: true)
    culture_minister = create(:ministerial_role, name: 'Secretary of State for Culture', cabinet_member: true)
    solicitor_general = create(:ministerial_role, name: 'Solicitor General', cabinet_member: false)
    prime_minister = create(:ministerial_role, name: 'Prime Minister', cabinet_member: true)
    defence_minister = create(:ministerial_role, name: 'Secretary of State for Defence', cabinet_member: true)
    first_sec_of_state = create(:ministerial_role, name: 'First Secretary of State', cabinet_member: true)

    create(:ministerial_role_appointment, role: deputy_prime_minister, person: nick_clegg)
    create(:ministerial_role_appointment, role: culture_minister, person: jeremy_hunt)
    create(:ministerial_role_appointment, role: solicitor_general, person: edward_garnier)
    create(:ministerial_role_appointment, role: prime_minister, person: david_cameron)
    create(:ministerial_role_appointment, role: defence_minister, person: philip_hammond)
    create(:ministerial_role_appointment, role: first_sec_of_state, person: davey_jones)

    get :index

    assert_equal [prime_minister, deputy_prime_minister, first_sec_of_state, defence_minister, culture_minister], assigns(:cabinet_ministerial_roles).map { |person, role| role.first.model }
  end

  test "should avoid n+1 queries" do
    MinisterialRole.expects(:includes).with(:current_people).returns([])
    get :index
  end

  test "shows the cabinet minister's name and role" do
    person = create(:person, forename: "John", surname: "Doe", image: File.open(Rails.root.join("test/fixtures/minister-of-funk.jpg")))
    ministerial_role = create(:ministerial_role, name: "Prime Minister", cabinet_member: true)
    create(:role_appointment, person: person, role: ministerial_role)

    get :index

    assert_select ".ministerial_role" do
      assert_select ".current-appointee", text: "John Doe"
      assert_minister_role_links_to_their_role(ministerial_role)
    end
  end

  test "shows the non-cabinet minister's photo, name and role" do
    person = create(:person, forename: "John", surname: "Doe", image: File.open(Rails.root.join("test/fixtures/minister-of-funk.jpg")))
    ministerial_role = create(:ministerial_role, name: "Prime Minister", cabinet_member: false)
    create(:role_appointment, person: person, role: ministerial_role)

    get :index

    assert_select ".ministerial_role" do
      assert_minister_photo_links_to_the_person(person)
      assert_select ".current-appointee a[href=?]", person_path(person), text: "John Doe"
      assert_minister_role_links_to_their_role(ministerial_role)
    end
  end

  test "shows only published news and speeches associated with ministerial role" do
    ministerial_role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: ministerial_role)
    published_speech = create(:published_speech, role_appointment: role_appointment)
    draft_speech = create(:draft_speech, role_appointment: role_appointment)
    published_news_article = create(:published_news_article, ministerial_roles: [ministerial_role])
    draft_news_article = create(:draft_news_article, ministerial_roles: [ministerial_role])

    get :show, id: ministerial_role

    assert_select_object(published_speech)
    refute_select_object(draft_speech)
    assert_select_object(published_news_article)
    refute_select_object(draft_news_article)
  end

  test "shows only news and speeches associated with ministerial role" do
    ministerial_role = create(:ministerial_role)
    another_ministerial_role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: ministerial_role)
    another_role_appointment = create(:role_appointment, role: another_ministerial_role)
    published_speech = create(:published_speech, role_appointment: role_appointment)
    another_published_speech = create(:published_speech, role_appointment: another_role_appointment)
    published_news_article = create(:published_news_article, ministerial_roles: [ministerial_role])
    another_published_news_article = create(:published_news_article, ministerial_roles: [another_ministerial_role])

    get :show, id: ministerial_role

    assert_select ".news_and_speeches" do
      assert_select_object(published_speech)
      refute_select_object(another_published_speech)
      assert_select_object(published_news_article)
      refute_select_object(another_published_news_article)
    end
  end

  test "shows most recent news and speeches at the top" do
    ministerial_role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: ministerial_role)
    newer_speech = create(:published_speech, role_appointment: role_appointment, first_published_at: 1.hour.ago)
    older_speech = create(:published_speech, role_appointment: role_appointment, first_published_at: 4.hours.ago)
    newer_news_article = create(:published_news_article, ministerial_roles: [ministerial_role], first_published_at: 2.hours.ago)
    older_news_article = create(:published_news_article, ministerial_roles: [ministerial_role], first_published_at: 3.hours.ago)

    get :show, id: ministerial_role

    assert_equal [newer_speech, newer_news_article, older_news_article, older_speech], assigns(:announcements)
  end

  test "should not display an empty published speeches section" do
    ministerial_role = create(:ministerial_role)

    get :show, id: ministerial_role

    refute_select ".news_and_speeches"
  end

  private

  def assert_minister_photo_links_to_the_person(person)
    assert_select ".image_holder a[href='#{person_path(person)}'] img[src='#{person.image_url}']"
  end

  def assert_minister_role_links_to_their_role(role)
    assert_select ".role a[href='#{ministerial_role_path(role)}']", text: role.name
  end
end
