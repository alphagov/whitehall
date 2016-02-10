require 'test_helper'

class PublishingApiPresenters::TopicalEventAboutPageTest < ActiveSupport::TestCase
  def present(record)
    PublishingApiPresenters::TopicalEventAboutPage.new(record)
  end

  test "topical event about page presentation includes the correct values" do
    topical_event_about_page = create(:topical_event_about_page)

    expected_hash = {
      base_path: topical_event_about_page.search_link,
      title: topical_event_about_page.name,
      description: 'Summary',
      format: 'topical_event_about_page',
      need_ids: [],
      locale: 'en',
      public_updated_at: topical_event_about_page.updated_at,
      update_type: 'major',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      routes: [
        { path: topical_event_about_page.search_link, type: 'exact' }
      ],
      redirects: [],
      details: {
        body: "<div class=\"govspeak\"><p>Body</p></div>",
        read_more: 'Read more'
      }
    }
    presented_item = present(topical_event_about_page)

    assert_valid_against_schema(presented_item.content, 'topical_event_about_page')
    assert_valid_against_links_schema({ links: presented_item.links }, 'topical_event_about_page')
    assert_equal topical_event_about_page.topical_event.content_id, presented_item.links[:parent][0]

    # We test for HTML equivalance rather than string equality to get around
    # inconsistencies with line breaks between different XML libraries
    assert_equivalent_html expected_hash[:details].delete(:body),
      presented_item.content[:details].delete(:body)

    assert_equal expected_hash.except(:details), presented_item.content.except(:details)
    assert_equal expected_hash[:details], presented_item.content[:details].except(:body)
  end
end
