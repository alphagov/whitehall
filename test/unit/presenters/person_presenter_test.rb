require 'test_helper'

class PersonPresenterTest < PresenterTestCase
  setup do
    @person = stub_translatable_record(:person)
    @presenter = PersonPresenter.new(@person, @view_context)
  end

  test 'path is generated using person_path' do
    assert_equal person_path(@person), @presenter.path
  end

  test 'link links name to path' do
    @presenter.stubs(:path).returns('http://example.com/person/a-person')
    assert_select_from @presenter.link, 'a[href="http://example.com/person/a-person"]', text: @person.name
  end

  test 'image returns an img tag' do
    @person.stubs(:image_url).returns('/link/to/image.jpg')
    assert_select_from @presenter.image, 'img[src="/link/to/image.jpg"]'
  end

  test 'image links to blank-person.png if person has no associated image' do
    @person.stubs(:image_url).returns(nil)
    assert_select_from @presenter.image, 'img[src="/government/assets/blank-person.png"]'
  end

  test 'biography generates html from the original govspeak' do
    @person.stubs(:biography).returns("## Hello")
    assert_select_from @presenter.biography, '.govspeak h2', text: 'Hello'
  end

  test "#announcements returns 10 published speeches and news articles sorted by descending date" do
    speech_1 = Speech.new
    speech_1.stubs(:public_timestamp).returns(1.days.ago)

    speech_2 = Speech.new
    speech_2.stubs(:public_timestamp).returns(30.days.ago)

    two_published_speeches = [ speech_1, speech_2 ]

    ten_published_news_articles = 10.times.map do |i|
      article = NewsArticle.new
      article.stubs(:public_timestamp).returns(i.days.ago - 3.days)
      article
    end

    @person.stubs(:published_speeches).returns(
      stub("all speeches", limit: two_published_speeches))
    @person.stubs(:published_news_articles).returns(
      stub("all news_articles", limit: ten_published_news_articles))
    assert_equal two_published_speeches[0..0] + ten_published_news_articles[0..8], @presenter.announcements.map(&:model)
  end

  test "is not available in multiple languages if person is not available in multiple languages" do
    role = stub_translatable_record(:role_without_organisations)
    role.stubs(:translated_locales).returns([:en, :fr])
    role_appointment = stub_record(:role_appointment, role: role, person: @person)

    @person.stubs(:current_role_appointments).returns([role_appointment])
    @person.stubs(:translated_locales).returns([:en])

    assert_equal [:en], @presenter.translated_locales
    refute @presenter.available_in_multiple_languages?
  end

  test "is not available in multiple languages if any current role is not available in multiple languages" do
    role_1 = stub_translatable_record(:role_without_organisations)
    role_1.stubs(:translated_locales).returns([:en])
    role_2 = stub_translatable_record(:role_without_organisations)
    role_2.stubs(:translated_locales).returns([:en, :es])
    role_appointment_1 = stub_record(:role_appointment, role: role_1, person: @person)
    role_appointment_2 = stub_record(:role_appointment, role: role_2, person: @person)

    @person.stubs(:current_role_appointments).returns([role_appointment_1, role_appointment_2])
    @person.stubs(:translated_locales).returns([:en, :es])

    assert_equal [:en], @presenter.translated_locales
    refute @presenter.available_in_multiple_languages?
  end

  test "is available in multiple languages if person and all current roles are available in the same multiple languages" do
    role_1 = stub_translatable_record(:role_without_organisations)
    role_1.stubs(:translated_locales).returns([:en, :es, :de, :it])
    role_2 = stub_translatable_record(:role_without_organisations)
    role_2.stubs(:translated_locales).returns([:en, :fr, :de, :it])
    role_appointment_1 = stub_record(:role_appointment, role: role_1, person: @person)
    role_appointment_2 = stub_record(:role_appointment, role: role_2, person: @person)

    @person.stubs(:current_role_appointments).returns([role_appointment_1, role_appointment_2])
    @person.stubs(:translated_locales).returns([:en, :fr, :es, :it])

    assert_equal [:en, :it], @presenter.translated_locales
    assert @presenter.available_in_multiple_languages?
  end
end
