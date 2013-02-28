require 'test_helper'

class Admin::GenericEditionsController::AuditTrailTest < ActionController::TestCase
  tests Admin::GenericEditionsController

  [:show, :edit].each do |action|
    view_test "should show who created the document and when on #{action}" do
      tom = login_as(create(:gds_editor, name: "Tom", email: "tom@example.com"))
      draft_edition = create(:draft_edition)

      request.env['HTTPS'] = 'on'
      get action, id: draft_edition

      assert_select ".audit-trail", text: /Created by Tom/ do
        assert_select "img[src^='https']"
      end
    end
  end
end