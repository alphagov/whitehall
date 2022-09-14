require "test_helper"

class OffsiteLinkTest < ActiveSupport::TestCase
  test "should be invalid without a title" do
    offsite_link = build(:offsite_link, title: nil)
    assert_not offsite_link.valid?
  end

  test "should be invalid without a summary" do
    offsite_link = build(:offsite_link, summary: nil)
    assert_not offsite_link.valid?
  end

  test "should be invalid without a url" do
    offsite_link = build(:offsite_link, url: nil)
    assert_not offsite_link.valid?
  end

  test "should be invalid with a url that is not part of gov.uk" do
    offsite_link = build(:offsite_link, url: "http://google.com")
    assert_not offsite_link.valid?
  end

  test "should be valid with a gov.uk url" do
    offsite_link = build(:offsite_link, url: "http://gov.uk/greatpage")
    assert offsite_link.valid?
  end

  test "should be valid within a subdomain of gov.uk" do
    offsite_link = build(:offsite_link, url: "http://education.gov.uk/greatpage")
    assert offsite_link.valid?
  end

  test "should be valid with a gov.wales url" do
    offsite_link = build(:offsite_link, url: "http://gov.wales/page")
    assert offsite_link.valid?
  end

  test "should be valid with a gov.scot url" do
    offsite_link = build(:offsite_link, url: "http://news.gov.scot/news/avian-influenza-5")
    assert offsite_link.valid?
  end

  test "should be valid with whitelisted urls" do
    whitelisted_urls = [
      "http://www.flu-lab-net.eu",
      "http://www.tse-lab-net.eu",
      "http://beisgovuk.citizenspace.com",
      "http://www.nhs.uk",
    ]
    whitelisted_urls.each do |url|
      assert build(:offsite_link, url: url).valid?, "#{url} not valid"
    end
  end

  test "should always be valid on Her Majesty Queen Elizabeth II's page" do
    topical_event = create(:topical_event, content_id: "7feaef73-a6a8-484a-8915-6efbbe4a8269")
    example_urls = [
      "https://www.royal.uk",
      "https://youtube.com",
      "http://example.com",
    ]
    example_urls.each do |url|
      assert build(:offsite_link, url: url, parent: topical_event).valid?, "#{url} not valid"
    end
  end

  test "should not be valid with almost whitelisted urls" do
    whitelisted_urls = [
      "http://someotherflu-lab-net.eu",
      "http://a.n.othertse-lab-net.eu",
      "http://almostbeisgovuk.citizenspace.com",
      "http://notthenhs.uk",
    ]
    whitelisted_urls.each do |url|
      assert_not build(:offsite_link, url: url).valid?, "#{url} is valid"
    end
  end

  test "should not be valid if the type is not supported" do
    offsite_link = build(:offsite_link, link_type: "notarealtype")
    assert_not offsite_link.valid?
  end

  test "should be valid if the type is alert" do
    offsite_link = build(:offsite_link, link_type: "alert")
    assert offsite_link.valid?
  end

  test "should be valid if the type is blog_post" do
    offsite_link = build(:offsite_link, link_type: "blog_post")
    assert offsite_link.valid?
  end

  test "should be valid if the type is campaign" do
    offsite_link = build(:offsite_link, link_type: "campaign")
    assert offsite_link.valid?
  end

  test "should be valid if the type is careers" do
    offsite_link = build(:offsite_link, link_type: "careers")
    assert offsite_link.valid?
  end

  test "should be valid if the type is manual" do
    offsite_link = build(:offsite_link, link_type: "manual")
    assert offsite_link.valid?
  end

  test "should be valid if the type is service" do
    offsite_link = build(:offsite_link, link_type: "service")
    assert offsite_link.valid?
  end

  test "should be valid if the type is nhs_content" do
    offsite_link = build(:offsite_link, link_type: "nhs_content")
    assert offsite_link.valid?
  end

  test "should be valid if the type is content_publisher_news_story" do
    offsite_link = build(:offsite_link, link_type: "content_publisher_news_story")
    assert offsite_link.valid?
  end

  test "should be valid if the type is content_publisher_press_release" do
    offsite_link = build(:offsite_link, link_type: "content_publisher_press_release")
    assert offsite_link.valid?
  end

  test "#destroy also destroys 'featured offsite link' associations" do
    offsite_link = create(:offsite_link)
    feature = create(:feature, offsite_link: offsite_link)
    feature_list = create(:feature_list, features: [feature])

    feature_list.reload
    assert_equal 1, feature_list.features.size

    offsite_link.destroy!

    feature_list.reload
    assert_equal 0, feature_list.features.size
  end
end
