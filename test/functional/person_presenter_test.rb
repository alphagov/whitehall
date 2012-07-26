require 'test_helper'

class PersonPresenterTest < PresenterTestCase
  setup do
    @person = stub_record(:person)
    @presenter = PersonPresenter.decorate(@person)
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
    two_published_speeches = [
      stub("speech1", delivered_on: 1.days.ago),
      stub("speech2", delivered_on: 30.days.ago)
    ]

    ten_published_news_articles = 10.times.map do |i| 
      stub("news_article_#{i}", published_at: i.days.ago - 3.days )
    end
    
    @person.stubs(:published_speeches).returns(
      stub("all speeches", limit: two_published_speeches))
    @person.stubs(:published_news_articles).returns(
      stub("all news_articles", limit: ten_published_news_articles))
    assert_equal two_published_speeches[0..0] + ten_published_news_articles[0..8], @presenter.announcements.map(&:model)
  end
end
