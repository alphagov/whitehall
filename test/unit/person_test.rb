require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :biography

  test "should be invalid without a name" do
    person = build(:person, title: nil, forename: nil, surname: nil, letters: nil)
    refute person.valid?
  end

  test '#ministerial_roles includes all ministerial roles' do
    minister = create(:ministerial_role)
    person = create(:person)
    create(:role_appointment, role: minister, person: person)
    assert_equal [minister], person.current_ministerial_roles
  end

  test '#ministerial_roles excludes non-ministerial roles' do
    permanent_secretary = create(:board_member_role)
    person = create(:person)
    create(:role_appointment, role: permanent_secretary, person: person)
    assert_equal [], person.current_ministerial_roles
  end

  test '#board_member_roles includes all non-ministerial roles' do
    permanent_secretary = create(:board_member_role)
    person = create(:person)
    create(:role_appointment, role: permanent_secretary, person: person)
    assert_equal [permanent_secretary], person.current_board_member_roles
  end

  test '#board_member_roles excludes any ministerial roles' do
    role_appointment = create(:ministerial_role_appointment)
    person = create(:person, role_appointments: [role_appointment])
    assert_equal [], person.current_board_member_roles
  end

  test '#previous_role_appointments include appointments that have ended' do
    person = create(:person)
    role_appointment = create(:ministerial_role_appointment, person: person, started_at: 1.year.ago, ended_at: 1.day.ago)
    assert_equal [role_appointment], person.previous_role_appointments
  end

  test '#previous_role_appointments excludes current appointments' do
    person = create(:person)
    role_appointment = create(:ministerial_role_appointment, person: person, started_at: 1.year.ago, ended_at: nil)
    assert_equal [], person.previous_role_appointments
  end

  test 'can access speeches associated via role_appointments' do
    person = create(:person)
    speech1 = create(:speech)
    speech2 = create(:speech)
    create(:role_appointment, person: person, speeches: [speech1])
    create(:role_appointment, person: person, speeches: [speech2])

    assert_equal [speech1, speech2], person.speeches
  end

  test 'can access news_articles associated with ministerial roles of a person' do
    person = create(:person)
    news_articles = 2.times.map { create(:news_article) }

    create(:ministerial_role_appointment, person: person).role.editions << news_articles[0]
    create(:ministerial_role_appointment, person: person).role.editions << news_articles[1]

    assert_equal news_articles, person.news_articles
  end

  test 'news_articles excludes articles associated with a previous ministerial role' do
    person = create(:person)
    news_articles = 2.times.map { create(:news_article) }

    create(:ministerial_role_appointment, person: person).role.editions << news_articles[0]
    create(:ministerial_role_appointment, person: person, started_at: 2.days.ago, ended_at: 1.day.ago)
      .role.editions << news_articles[1]

    assert_equal news_articles[0..0], person.news_articles
  end

  test 'published_news_articles only returns published news articles' do
    person = create(:person)
    news_articles = [create(:published_news_article), create(:draft_news_article)]

    create(:ministerial_role_appointment, person: person).role.editions << news_articles[0]
    create(:ministerial_role_appointment, person: person).role.editions << news_articles[1]

    assert_equal news_articles[0..0], person.published_news_articles
  end

  test "should not be destroyable when it has appointments" do
    person = create(:person, role_appointments: [create(:role_appointment)])
    refute person.destroyable?
    assert_equal false, person.destroy
  end

  test "should be destroyable when it has no appointments" do
    person = create(:person, role_appointments: [])
    assert person.destroyable?
    assert person.destroy
  end

  test 'uses only forename and surname as slug if person has forename' do
    person = create(:person, title: 'Sir', forename: 'Hercule', surname: 'Poirot')
    assert_equal 'hercule-poirot', person.slug
  end

  test 'uses title and surname for slug if person has empty forename' do
    person = create(:person, title: 'Lord', forename: '', surname: 'Barry of Toxteth')
    assert_equal 'lord-barry-of-toxteth', person.slug
  end

  test 'should generate sort key from surname and first name' do
    person = Person.new(forename: 'Hercule', surname: 'Poirot')
    assert_equal 'poirot hercule', person.sort_key
  end
end
