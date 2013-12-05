require 'test_helper'

class PersonPresenterTest < ActionView::TestCase
  setup do
    setup_view_context
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

  test "#announcements returns decorated published speeches and news articles available in the current locale in descending date" do
    speech_1 = build(:published_speech, first_published_at: 1.day.ago)
    speech_2 = build(:published_speech, first_published_at: 30.days.ago, translated_into: :cy)
    speech_3 = build(:draft_speech)
    news_1   = build(:published_news_article, first_published_at: 4.days.ago, translated_into: :cy)
    role_appointment = create(:ministerial_role_appointment, news_articles: [news_1], speeches: [speech_1, speech_2])
    presenter = PersonPresenter.new(role_appointment.person)

    assert_equal [speech_1, news_1, speech_2], presenter.announcements.map(&:model)

    I18n.with_locale(:cy) do
      assert_equal [news_1, speech_2], presenter.announcements.map(&:model)
    end
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
