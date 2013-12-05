require 'test_helper'

class RolePresenterTest < ActionView::TestCase
  setup do
    setup_view_context
    @role = stub_translatable_record(:role_without_organisations)
    @presenter = RolePresenter.new(@role, @view_context)
  end

  test 'path is the ministerial_role_path if role is ministerial' do
    @role.stubs(:ministerial?).returns(true)
    assert_equal ministerial_role_path(@role), @presenter.path
  end

  test 'path is nil if appointed role is not ministerial' do
    @role.stubs(:ministerial?).returns(false)
    assert_nil @presenter.path
  end

  test 'link links name to path if path available' do
    @presenter.stubs(:path).returns('http://example.com/ministers/minister-of-funk')
    @role.stubs(:name).returns('The Minister of Funk')
    assert_select_from @presenter.link, 'a[href="http://example.com/ministers/minister-of-funk"]', text: 'The Minister of Funk'
  end

  test 'link returns just name if path unavailable' do
    @presenter.stubs(:path).returns(nil)
    @role.stubs(:name).returns('The Minister of Funk')
    assert_equal 'The Minister of Funk', @presenter.link
  end

  test 'current_person returns a PersonPresenter for the current appointee' do
    @role.stubs(:current_person).returns(stub_translatable_record(:person))
    assert_equal @presenter.current_person, PersonPresenter.new(@role.current_person, @view_context)
  end

  test 'current_person returns a UnassignedPersonPresenter if there is no current appointee' do
    @role.stubs(:current_person).returns(nil)
    assert_equal @presenter.current_person, RolePresenter::UnassignedPersonPresenter.new(nil, @view_context)
  end

  test 'responsibilities generates html from the original govspeak' do
    @role.stubs(:responsibilities).returns("## Hello")
    assert_select_from @presenter.responsibilities, '.govspeak h2', text: 'Hello'
  end

  test "#announcements returns 10 published speeches and news articles sorted by descending date" do
    organisation = stub_record(:organisation, organisation_type_key: :ministerial_department)
    @role = stub_record(:ministerial_role, organisations: [organisation])
    @presenter = RolePresenter.new(@role, @view_context)

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

    @role.stubs(:published_speeches).returns(
      stub("all speeches", limit: two_published_speeches))
    @role.stubs(:published_news_articles).returns(
      stub("all news_articles", limit: ten_published_news_articles))
    assert_equal two_published_speeches[0..0] + ten_published_news_articles[0..8], @presenter.announcements.map(&:model)
  end

  test '#published_policies returns decorated published policies available in the current locale' do
    role = create(:ministerial_role)
    english_policy = create(:published_policy, ministerial_roles: [role])
    welsh_policy   = create(:published_policy, ministerial_roles: [role], translated_into: 'cy')
    presenter = RolePresenter.new(role, @view_content)

    assert_equal [PolicyPresenter.new(welsh_policy), PolicyPresenter.new(english_policy)], presenter.published_policies

    I18n.with_locale(:cy) do
      assert_equal [PolicyPresenter.new(welsh_policy)], presenter.published_policies
    end
  end
end
