require 'test_helper'

class AttachableEditionsWithInlineSupportTest < ActionController::TestCase
  tests Admin::NewsArticlesController

  setup { login_as :policy_writer }

  view_test 'GET :edit lists the attachments with markdown hint for editions that support inline attachments' do
    edition = create(:news_article, :with_attachment)
    get :edit, id: edition
    attachment = edition.attachments.first

    assert_select 'span.title', attachment.title
    assert_select "#govspeak_help", text: /Attachments/
    assert_select 'fieldset.attachments input[readonly][value=!@1]'
  end
end

class AttachableEditionWithoutInlineSupportTest < ActionController::TestCase
  tests Admin::PublicationsController

  setup { login_as :policy_writer }

  view_test 'GET :edit lists the attachments without markdown hints for editions that do not support inline attachments' do
    edition = create(:publication, :with_attachment)
    get :edit, id: edition
    attachment = edition.attachments.first

    assert_select 'span.title', attachment.title
    assert_select 'fieldset.attachments input[readonly][value=!@1]', count: 0
  end
end
