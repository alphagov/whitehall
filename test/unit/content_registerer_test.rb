require 'test_helper'
require 'gds_api/test_helpers/content_register'

class ContentRegistererTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::ContentRegister

  test "registers models with the content register" do
    organisation = create(:organisation)
    expected_entry = {
      base_path: organisation.search_index['link'],
      format: 'organisation',
      title: organisation.name
    }

    expected_request = stub_content_register_put_entry(organisation.content_id, expected_entry)

    ContentRegisterer.new(Organisation.all).register!

    assert_requested expected_request
  end
end
