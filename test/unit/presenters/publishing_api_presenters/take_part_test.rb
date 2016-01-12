require 'test_helper'

class PublishingApiPresenters::TakePartTest < ActiveSupport::TestCase
  def present(record)
    PublishingApiPresenters::TakePart.new(record).as_json
  end

  test "case study presentation includes the correct values" do
    # TODO move setting content_id to model
    take_part_page = create(:take_part_page, content_id: SecureRandom.uuid)

    image_url = Whitehall.asset_root + take_part_page.image_url(:s300)

    expected_hash = {
      base_path: take_part_page.search_link,
      content_id: take_part_page.content_id,
      title: 'A take part page title',
      description: 'Summary text',
      format: 'take_part',
      locale: 'en',
      public_updated_at: take_part_page.updated_at,
      update_type: 'major',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
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
      }
    }
    presented_hash = present(take_part_page)

    assert_valid_against_schema(presented_hash, 'take_part')

    assert_equal expected_hash.except(:details),
      presented_hash.except(:details)

    # We test for HTML equivalance rather than string equality to get around
    # inconsistencies with line breaks between different XML libraries
    assert_equivalent_html expected_hash[:details].delete(:body),
      presented_hash[:details].delete(:body)

    assert_equal expected_hash[:details], presented_hash[:details]
  end
end
