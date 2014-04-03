require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :biography

  test "#columns excludes biography so that we can safely it from editions in a future migration" do
    # This test ensure that we're excluding the biography column from Person.columns.
    # You can safely remove this, and Person.columns, once it's been deployed and we've subsequently removed
    # this column for real.
    refute Person.columns.map(&:name).include?('biography')
  end

  test 'should return search index data suitable for Rummageable' do
    person = create(:person, forename: 'David', surname: 'Cameron', biography: 'David Cameron became Prime Minister in May 2010.')

    assert_equal({
                  'title' => 'David Cameron',
                  'link' => '/government/people/david-cameron',
                  'indexable_content' => 'David Cameron became Prime Minister in May 2010.',
                  'format' => 'person',
                  'description' => '',
                  'slug' => 'david-cameron'
                  }, person.search_index)
  end

  test "should be invalid without a name" do
    person = build(:person, title: nil, forename: nil, surname: nil, letters: nil)
    refute person.valid?
  end

  test "should be invalid if image isn't 960x640px" do
    person = build(:person, image: File.open(Rails.root.join('test/fixtures/horrible-image.64x96.jpg')))
    refute person.valid?
  end

  test "should be valid if legacy image isn't 960x640px" do
    person = build(:person, slug: 'stubbed', image: File.open(Rails.root.join('test/fixtures/horrible-image.64x96.jpg')))
    person.save(validate: false)
    assert person.reload.valid?
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

  test '#organisations includes organisations linked through current ministerial roles' do
    person = create(:person)
    role_appointment = create(:ministerial_role_appointment, person: person, started_at: 1.year.ago, ended_at: nil)
    assert_equal role_appointment.role.organisations, person.organisations
  end

  test '#organisations excludes organisations linked through past ministerial roles' do
    person = create(:person)
    role_appointment = create(:ministerial_role_appointment, person: person, started_at: 1.year.ago, ended_at: 1.day.ago)
    assert_equal [], person.organisations
  end

  test '#organisations includes organisations linked through current board member roles' do
    person = create(:person)
    role_appointment = create(:board_member_role_appointment, person: person, started_at: 1.year.ago, ended_at: nil)
    assert_equal role_appointment.role.organisations, person.organisations
  end

  test '#organisations excludes organisations linked through past board member roles roles' do
    person = create(:person)
    role_appointment = create(:board_member_role_appointment, person: person, started_at: 1.year.ago, ended_at: 1.day.ago)
    assert_equal [], person.organisations
  end

  test 'can access speeches associated via role_appointments' do
    person = create(:person)
    speech1 = create(:draft_speech, role_appointment: create(:role_appointment, person: person))
    speech2 = create(:draft_speech, role_appointment: create(:role_appointment, person: person))

    assert_equal [speech1, speech2], person.speeches
  end

  test 'can access news_articles associated with ministerial roles of a person' do
    person = create(:person)
    news_articles = 2.times.map { create(:news_article) }

    create(:ministerial_role_appointment, person: person).editions << news_articles[0]
    create(:ministerial_role_appointment, person: person).editions << news_articles[1]

    assert_equal news_articles, person.news_articles
  end

  test 'news_articles includes articles associated with a previous ministerial role' do
    person = create(:person)
    news_articles = 2.times.map { create(:news_article) }

    create(:ministerial_role_appointment, person: person).editions << news_articles[0]
    create(:ministerial_role_appointment, person: person, started_at: 2.days.ago, ended_at: 1.day.ago)
      .editions << news_articles[1]

    assert_equal news_articles, person.news_articles
  end

  test 'published_news_articles only returns published news articles' do
    person = create(:person)
    news_articles = [create(:published_news_article), create(:draft_news_article)]

    create(:ministerial_role_appointment, person: person).editions << news_articles[0]
    create(:ministerial_role_appointment, person: person).editions << news_articles[1]
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

  test 'should not change the slug when the name is changed' do
    person = create(:person, forename: "John", surname: "Smith")
    person.update_attributes(forename: "Joe", surname: "Bloggs")
    assert_equal 'john-smith', person.slug
  end

  test "should not include apostrophes in slug" do
    person = create(:person, forename: "Tim", surname: "O'Reilly")
    assert_equal 'tim-oreilly', person.slug
  end

  test 'should generate sort key from surname and first name' do
    person = Person.new(forename: 'Hercule', surname: 'Poirot')
    assert_equal 'poirot hercule', person.sort_key
  end

  test 'name should not have trailing whitespace' do
    assert_equal 'Claire Moriarty', build(:person, title: '', forename: 'Claire', surname: 'Moriarty', letters: '').name
  end

  test '#ministerial_roles_at returns the ministerial roles held by the person at the date specified' do
    person = create(:person)
    oldest_role = create(:ministerial_role)
    older_role = create(:ministerial_role)
    newer_role = create(:ministerial_role)
    newest_role = create(:ministerial_role)
    current_non_ministerial_role = create(:board_member_role)
    create(:role_appointment, person: person, role: oldest_role, started_at: 12.months.ago, ended_at: 8.months.ago)
    create(:role_appointment, person: person, role: older_role, started_at: 8.months.ago, ended_at: 5.months.ago)
    create(:role_appointment, person: person, role: newer_role, started_at: 7.months.ago, ended_at: 4.months.ago)
    create(:role_appointment, person: person, role: newest_role, started_at: 4.months.ago, ended_at: nil)
    create(:role_appointment, person: person, role: current_non_ministerial_role, started_at: 1.month.ago, ended_at: nil)

    assert_equal [oldest_role], person.ministerial_roles_at(9.months.ago)
    assert_equal [older_role, newer_role], person.ministerial_roles_at(6.months.ago)
    assert_equal [newest_role], person.ministerial_roles_at(1.month.ago)
  end

  test '#role_appointments_at returns the role appointments held by the person at the date specified' do
    person = create(:person)
    oldest_role_appointment = create(:role_appointment, person: person, started_at: 12.months.ago, ended_at: 8.months.ago)
    overlapping_role_appointment_1 = create(:role_appointment, person: person, started_at: 8.months.ago, ended_at: 5.months.ago)
    overlapping_role_appointment_2 = create(:role_appointment, person: person, started_at: 7.months.ago, ended_at: 4.months.ago)
    current_role_appointment = create(:role_appointment, person: person, started_at: 4.months.ago, ended_at: nil)

    assert_equal [oldest_role_appointment], person.role_appointments_at(9.months.ago)
    assert_equal [overlapping_role_appointment_1, overlapping_role_appointment_2], person.role_appointments_at(6.months.ago)
    assert_equal [current_role_appointment], person.role_appointments_at(1.month.ago)
  end

  test "has removeable translations" do
    person = create(:person, translated_into: {
      fr: { biography: "french-biography" },
      es: { biography: "spanish-biography" }
    })
    person.remove_translations_for(:fr)
    refute person.translated_locales.include?(:fr)
    assert person.translated_locales.include?(:es)
  end

  test '#without_current_ministerial_roles finds people with no roles' do
    person = create(:person)

    assert_includes Person.without_a_current_ministerial_role, person
  end

  test '#without_a_current_ministerial_role finds people with a ministerial role that has ended' do
    person = create(:person)
    create(:ministerial_role_appointment, person: person, started_at: 2.years.ago, ended_at: 1.day.ago)

    assert_includes Person.without_a_current_ministerial_role, person
  end

  test '#without_current_ministerial_roles finds people with current role that is not ministerial' do
    person = create(:person)
    create(:role_appointment, person: person)

    assert_includes Person.without_a_current_ministerial_role, person
  end

  test '#without_current_ministerial_roles does not include people with a current ministerial role' do
    person = create(:person)
    mini_role = create(:ministerial_role_appointment, person: person)

    refute_includes Person.without_a_current_ministerial_role, person
  end

  test '#can_have_historical_accounts? returns true when person has roles that support them' do
    person = create(:person)
    refute person.can_have_historical_accounts?

    create(:role_appointment, person: person)
    refute person.reload.can_have_historical_accounts?

    create(:historic_role_appointment, person: person)
    assert person.reload.can_have_historical_accounts?
  end
end
