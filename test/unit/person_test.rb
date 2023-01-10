require "test_helper"

class PersonTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :person, :biography

  test "should be invalid without a name" do
    person = build(:person, title: nil, forename: nil, surname: nil, letters: nil)
    assert_not person.valid?
  end

  test "should strip whitespace from names" do
    person = build(:person, forename: " forename ", surname: " surname ")
    assert_equal "forename surname", person.name
  end

  test "should be invalid if image isn't 960x640px" do
    person = build(:person, image: File.open(Rails.root.join("test/fixtures/horrible-image.64x96.jpg")))
    assert_not person.valid?
  end

  test "should be valid if legacy image isn't 960x640px" do
    person = build(
      :person,
      slug: "stubbed",
      image: File.open(Rails.root.join("test/fixtures/horrible-image.64x96.jpg")),
      content_id: SecureRandom.uuid,
    )
    person.save!(validate: false)
    assert person.reload.valid?
  end

  test "#organisations includes organisations linked through current ministerial roles" do
    person = create(:person)
    role_appointment = create(:ministerial_role_appointment, person:, started_at: 1.year.ago, ended_at: nil)
    assert_equal role_appointment.role.organisations, person.reload.organisations
  end

  test "#organisations excludes organisations linked through past ministerial roles" do
    person = create(:person)
    create(:ministerial_role_appointment, person:, started_at: 1.year.ago, ended_at: 1.day.ago)
    assert_equal [], person.reload.organisations
  end

  test "#organisations includes organisations linked through current board member roles" do
    person = create(:person)
    role_appointment = create(:board_member_role_appointment, person:, started_at: 1.year.ago, ended_at: nil)
    assert_equal role_appointment.role.organisations, person.reload.organisations
  end

  test "#organisations excludes organisations linked through past board member roles roles" do
    person = create(:person)
    create(:board_member_role_appointment, person:, started_at: 1.year.ago, ended_at: 1.day.ago)
    assert_equal [], person.reload.organisations
  end

  test "can access speeches associated via role_appointments" do
    person = create(:person)
    speech1 = create(:draft_speech, role_appointment: create(:role_appointment, person:))
    speech2 = create(:draft_speech, role_appointment: create(:role_appointment, person:))

    assert_equal [speech1, speech2], person.speeches
  end

  test "published_speeches only returns published speeches" do
    person = create(:person)
    published_speech = create(:published_speech, role_appointment: create(:role_appointment, person:))
    create(:draft_speech, role_appointment: create(:role_appointment, person:))
    create(:speech, :withdrawn, role_appointment: create(:role_appointment, person:))

    assert_equal [published_speech], person.published_speeches
  end

  test "can access news_articles associated with ministerial roles of a person" do
    person = create(:person)
    news_articles = 2.times.map { create(:news_article) }

    create(:ministerial_role_appointment, person:).editions << news_articles[0]
    create(:ministerial_role_appointment, person:).editions << news_articles[1]

    assert_equal news_articles, person.news_articles
  end

  test "news_articles includes articles associated with a previous ministerial role" do
    person = create(:person)
    news_articles = 2.times.map { create(:news_article) }

    create(:ministerial_role_appointment, person:).editions << news_articles[0]
    create(:ministerial_role_appointment, person:, started_at: 2.days.ago, ended_at: 1.day.ago)
      .editions << news_articles[1]

    assert_equal news_articles, person.news_articles
  end

  test "published_news_articles only returns published news articles" do
    person = create(:person)
    news_articles = [create(:published_news_article), create(:draft_news_article), create(:news_article, :withdrawn)]
    news_articles.each do |edition|
      create(:ministerial_role_appointment, person:).editions << edition
    end

    assert_equal news_articles[0..0], person.published_news_articles
  end

  test "should not be destroyable when it has appointments" do
    person = create(:person)
    _ = create(:role_appointment, person:)
    assert_not person.destroyable?
    assert_equal false, person.destroy
  end

  test "should be destroyable when it has no appointments" do
    person = create(:person, role_appointments: [])
    assert person.destroyable?
    assert person.destroy
  end

  test "uses only forename and surname as slug if person has forename" do
    person = create(:person, title: "Sir", forename: "Hercule", surname: "Poirot")
    assert_equal "hercule-poirot", person.slug
  end

  test "uses title and surname for slug if person has empty forename" do
    person = create(:person, title: "Lord", forename: "", surname: "Barry of Toxteth")
    assert_equal "lord-barry-of-toxteth", person.slug
  end

  test "should not change the slug when the name is changed" do
    person = create(:person, forename: "John", surname: "Smith")
    person.update!(forename: "Joe", surname: "Bloggs")
    assert_equal "john-smith", person.slug
  end

  test "should not include apostrophes in slug" do
    person = create(:person, forename: "Tim", surname: "O'Reilly")
    assert_equal "tim-oreilly", person.slug
  end

  test "should generate sort key from surname and first name" do
    person = Person.new(forename: "Hercule", surname: "Poirot")
    assert_equal "poirot hercule", person.sort_key
  end

  test "name should not have trailing whitespace" do
    assert_equal "Claire Moriarty", build(:person, title: "", forename: "Claire", surname: "Moriarty", letters: "").name
  end

  test "has removeable translations" do
    stub_any_publishing_api_call

    person = create(
      :person,
      translated_into: {
        fr: { biography: "french-biography" },
        es: { biography: "spanish-biography" },
      },
    )
    person.remove_translations_for(:fr)
    assert_not person.translated_locales.include?(:fr)
    assert person.translated_locales.include?(:es)
  end

  test "#can_have_historical_accounts? returns true when person has roles that support them" do
    person = create(:person)
    assert_not person.can_have_historical_accounts?

    create(:role_appointment, person:)
    assert_not person.reload.can_have_historical_accounts?

    create(:historic_role_appointment, person:)
    assert person.reload.can_have_historical_accounts?
  end

  test "#name_with_disambiguator returns string with containing a persons name, role and org" do
    person = create(:person)
    role_appointment = create(:role_appointment, person:)

    assert "#{person.name} - #{role_appointment.role.name} - #{person.organisations.first.name}",
           person.name_with_disambiguator
  end

  test "touches any person appointments after being updated" do
    person = create(:person)
    role_appointment = create(:role_appointment, person:)

    Timecop.freeze 1.month do
      person.update!(surname: "Smith")

      assert_equal Time.zone.now, role_appointment.reload.updated_at
    end
  end

  test "#current_or_previous_prime_minister returns true when the persons ministerial_roles includes Prime Minister" do
    person = build(:person)
    prime_minister_role = build(:ministerial_role, slug: "prime-minister")
    person.stubs(:ministerial_roles).returns([prime_minister_role])

    assert_equal true, person.current_or_previous_prime_minister?
  end

  test "#current_or_previous_prime_minister returns false when the persons ministerial_roles does not include Prime Minister" do
    person = build(:person)

    assert_equal false, person.current_or_previous_prime_minister?
  end
end
