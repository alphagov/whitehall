require 'test_helper'

class Admin::GenericEditionsController::AuditTrailTest < ActionController::TestCase
  include TaxonomyHelper
  tests Admin::GenericEditionsController

  %i[show edit].each do |action|
    view_test "should show who created the document and when on #{action}" do
      login_as(create(:gds_editor, name: "Tom", email: "tom@example.com"))

      draft_edition = create(:draft_edition)
      stub_publishing_api_expanded_links_with_taxons(draft_edition.content_id, [])

      request.env['HTTPS'] = 'on'
      get action, params: { id: draft_edition }

      assert_select "#history", text: /Created by Tom/ do
        assert_select "img[src^='https']"
      end
    end
  end
end
