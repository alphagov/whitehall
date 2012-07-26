require 'test_helper'

class RolePresenterTest < PresenterTestCase
  setup do
    @role = stub_record(:role)
    @presenter = RolePresenter.decorate(@role)
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
    @role.stubs(:current_person).returns(stub_record(:person))
    assert_equal @presenter.current_person, PersonPresenter.new(@role.current_person)
  end

  test 'current_person returns a UnassignedPersonPresenter if there is no current appointee' do
    @role.stubs(:current_person).returns(nil)
    assert_equal @presenter.current_person, RolePresenter::UnassignedPersonPresenter.new(nil)
  end

  test 'responsibilities generates html from the original govspeak' do
    @role.stubs(:responsibilities).returns("## Hello")
    assert_select_from @presenter.responsibilities, '.govspeak h2', text: 'Hello'
  end

  test "#announcements returns 10 published speeches and news articles sorted by descending date" do
    @role = stub_record(:ministerial_role)
    @presenter = RolePresenter.decorate(@role)

    two_published_speeches = [
      stub("speech1", delivered_on: 1.days.ago),
      stub("speech2", delivered_on: 30.days.ago)
    ]

    ten_published_news_articles = 10.times.map do |i| 
      stub("news_article_#{i}", published_at: i.days.ago - 3.days )
    end
    
    @role.stubs(:published_speeches).returns(
      stub("all speeches", limit: two_published_speeches))
    @role.stubs(:published_news_articles).returns(
      stub("all news_articles", limit: ten_published_news_articles))
    assert_equal two_published_speeches[0..0] + ten_published_news_articles[0..8], @presenter.announcements.map(&:model)
  end
end
