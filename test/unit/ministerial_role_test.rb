require 'test_helper'

class MinisterialRoleTest < ActiveSupport::TestCase
  test "should set a slug from the ministerial role name" do
    role = create(:ministerial_role, name: 'Prime Minister, Cabinet Office')
    assert_equal 'prime-minister-cabinet-office', role.slug
  end

  test "should not change the slug when the name is changed" do
    role = create(:ministerial_role, name: 'Prime Minister, Cabinet Office')
    role.update_attributes(name: 'Prime Minister')
    assert_equal 'prime-minister-cabinet-office', role.slug
  end

  test "should be able to get policies associated with a role" do
    editions = [create(:published_policy), create(:published_news_article)]
    ministerial_role = create(:ministerial_role, editions: editions)
    assert_equal editions[0..0], ministerial_role.policies
  end

  test "should be able to get published policies associated with a role" do
    editions = [create(:published_policy), create(:draft_policy), create(:superseded_policy)]
    ministerial_role = create(:ministerial_role, editions: editions)
    assert_equal editions[0..0], ministerial_role.published_policies
  end

  test "should be able to get news_articles associated with a role" do
    editions = [create(:published_policy), create(:published_news_article)]
    ministerial_role = create(:ministerial_role)
    appointment = create(:role_appointment, role: ministerial_role, editions: editions)
    assert_equal editions[1..1], ministerial_role.news_articles
  end

  test "should be able to get published news_articles associated with the role" do
    editions = [create(:draft_news_article), create(:published_news_article)]
    ministerial_role = create(:ministerial_role)
    appointment = create(:role_appointment, role: ministerial_role, editions: editions)
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
    appointment = create(:ministerial_role_appointment,
      started_at: 1.day.ago,
      ended_at: nil)
    create(:published_speech, role_appointment: appointment)
    create(:draft_speech, role_appointment: appointment)

    assert appointment.role.published_speeches.all? {|s| s.published?}
    assert_equal 1, appointment.role.published_speeches.count
  end

  test "published_speeches should not return speeches from previous appointees" do
    appointment = create(:ministerial_role_appointment,
      started_at: 2.days.ago,
      ended_at: 1.day.ago)
    create(:published_speech, role_appointment: appointment)

    assert_equal 1, appointment.role.published_speeches.count
  end

  test "should not be destroyable when it is responsible for editions" do
    ministerial_role = create(:ministerial_role, editions: [create(:edition)])
    refute ministerial_role.destroyable?
    assert_equal false, ministerial_role.destroy
  end

  test "should be destroyable when it has no appointments, organisations or editions" do
    ministerial_role = create(:ministerial_role_without_organisation, role_appointments: [], organisations: [], editions: [])
    assert ministerial_role.destroyable?
    assert ministerial_role.destroy
  end

  test "can never be a permanent secretary" do
    ministerial_role = build(:ministerial_role)
    refute ministerial_role.permanent_secretary?
  end

  test "can never be a chief of the defence staff" do
    ministerial_role = build(:ministerial_role)
    refute ministerial_role.chief_of_the_defence_staff?
  end

  test 'should return search index data suitable for Rummageable' do
    person = create(:person, forename: 'David', surname: 'Cameron', biography: 'David Cameron became Prime Minister in May 2010.')
    ministerial_role = create(:ministerial_role_without_organisation, name: 'Prime Minister')
    create(:ministerial_role_appointment, role: ministerial_role, person: person)

    assert_equal 'David Cameron (Prime Minister)', ministerial_role.search_index['title']
    assert_equal "/government/ministers/#{ministerial_role.slug}", ministerial_role.search_index['link']
    assert_equal 'David Cameron became Prime Minister in May 2010.', ministerial_role.search_index['indexable_content']
    assert_equal 'minister', ministerial_role.search_index['format']
  end

  test 'should add ministerial role to search index on creating' do
    ministerial_role = build(:ministerial_role_without_organisation)

    Whitehall::SearchIndex.expects(:add).with(ministerial_role)

    ministerial_role.save
  end

  test 'should add ministerial role to search index on updating' do
    ministerial_role = create(:ministerial_role_without_organisation)

    Whitehall::SearchIndex.expects(:add).with(ministerial_role)

    ministerial_role.name = 'Ministry of Junk'
    ministerial_role.save
  end

  test 'should remove ministerial role from search index on destroying' do
    ministerial_role = create(:ministerial_role_without_organisation)
    Whitehall::SearchIndex.expects(:delete).with(ministerial_role)
    ministerial_role.destroy
  end

  test 'should return search index data for all ministerial roles' do
    nick_clegg = create(:person, forename: 'Nick', surname: 'Clegg', biography: 'Cleggy.')
    jeremy_hunt = create(:person, forename: 'Jeremy', surname: 'Hunt', biography: 'Hunty.')
    edward_garnier = create(:person, forename: 'Edward', surname: 'Garnier', biography: 'Garnerian.')
    david_cameron = create(:person, forename: 'David', surname: 'Cameron', biography: 'Cameronian.')

    deputy_prime_minister = create(:ministerial_role_without_organisation, name: 'Deputy Prime Minister', cabinet_member: true)
    culture_minister = create(:ministerial_role_without_organisation, name: 'Secretary of State for Culture', cabinet_member: true)
    solicitor_general = create(:ministerial_role_without_organisation, name: 'Solicitor General', cabinet_member: false)
    prime_minister = create(:ministerial_role_without_organisation, name: 'Prime Minister', cabinet_member: true)

    create(:ministerial_role_appointment, role: deputy_prime_minister, person: nick_clegg)
    create(:ministerial_role_appointment, role: culture_minister, person: jeremy_hunt)
    create(:ministerial_role_appointment, role: solicitor_general, person: edward_garnier)
    create(:ministerial_role_appointment, role: prime_minister, person: david_cameron)

    results = MinisterialRole.search_index.to_a

    assert_equal 4, results.length
    assert_equal({'title' => 'Nick Clegg (Deputy Prime Minister)',
                  'link' => '/government/ministers/deputy-prime-minister',
                  'indexable_content' => 'Cleggy.',
                  'format' => 'minister',
                  'description' => ''}, results[0])
    assert_equal({'title' => 'Jeremy Hunt (Secretary of State for Culture)',
                  'link' => '/government/ministers/secretary-of-state-for-culture',
                  'indexable_content' => 'Hunty.',
                  'format' => 'minister',
                  'description' => ''}, results[1])
    assert_equal({'title' => 'Edward Garnier (Solicitor General)',
                  'link' => '/government/ministers/solicitor-general',
                  'indexable_content' => 'Garnerian.',
                  'format' => 'minister',
                  'description' => ''}, results[2])
    assert_equal({'title' => 'David Cameron (Prime Minister)',
                  'link' => '/government/ministers/prime-minister',
                  'indexable_content' => 'Cameronian.',
                  'format' => 'minister',
                  'description' => ''}, results[3])
  end

  test "#current_person_name should return the role name when vacant" do
    role = create(:ministerial_role, name: "Minister of Importance", people: [])
    assert_equal "Minister of Importance", role.current_person_name
  end
end
