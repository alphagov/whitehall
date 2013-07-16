require 'test_helper'

class AttachableEditionTest < ActionController::TestCase
  tests Admin::NewsArticlesController

  setup { login_as :policy_writer }

  def assert_tab(link_text, path)
    assert_select "ul.nav-tabs li a[href*=#{path}]", link_text
  end

  view_test 'GET :new displays a "Document" tab' do
    get :new
    assert_tab 'Document', new_admin_news_article_path
  end

  view_test 'GET :edit displays "Document" and "Attachments" tabs' do
    edition = create(:news_article)
    get :edit, id: edition
    assert_tab 'Document', edit_admin_news_article_path(edition)
    assert_tab 'Attachments', admin_edition_attachments_path(edition)
  end
end

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
