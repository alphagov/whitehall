require 'test_helper'

class PublishingApi::TakePartPresenterTest < ActiveSupport::TestCase
  def present(record)
    PublishingApi::TakePartPresenter.new(record)
  end

  test "take part presentation includes the correct values" do
    take_part_page = create(:take_part_page, content_id: SecureRandom.uuid)

    image_url = Whitehall.public_asset_host + take_part_page.image_url(:s300)

    expected_hash = {
      base_path: take_part_page.search_link,
      title: 'A take part page title',
      description: 'Summary text',
      schema_name: 'take_part',
      document_type: 'take_part',
      locale: 'en',
      public_updated_at: take_part_page.updated_at,
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
      routes: [
        { path: take_part_page.search_link, type: 'exact' }
      ],
      redirects: [],
      details: {
        body: "<div class=\"govspeak\"><p>Some govspeak body text</p></div>",
        image: {
          url: image_url,
          alt_text: "Image alt text"
        }
      },
      update_type: "major",
    }

    presented_item = present(take_part_page)
    presented_content = presented_item.content

    assert_valid_against_schema(presented_content, 'take_part')
    assert_valid_against_links_schema({ links: presented_item.links }, 'take_part')

    # We test for HTML equivalance rather than string equality to get around
    # inconsistencies with line breaks between different XML libraries
    assert_equivalent_html expected_hash[:details].delete(:body),
      presented_content[:details].delete(:body)

    assert_equal expected_hash, presented_content
  end
end
