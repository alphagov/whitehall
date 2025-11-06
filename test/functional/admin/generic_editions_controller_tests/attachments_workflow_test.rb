require "test_helper"

class AttachableEditionTest < ActionController::TestCase
  tests Admin::NewsArticlesController

  setup { login_as :writer }

  def assert_tab(link_text, path)
    assert_select ".app-c-secondary-navigation__list .app-c-secondary-navigation__list-item  .govuk-link[href*=?]", path, link_text
  end

  def assert_not_tab(link_text)
    assert_select ".app-c-secondary-navigation__list .app-c-secondary-navigation__list-item", link_text, count: 0
  end

  view_test 'GET :new displays a "Document" tab' do
    get :new
    assert_tab "Document", new_admin_news_article_path
  end

  view_test 'GET :edit displays "Document" and "Attachments" tabs' do
    edition = create(:news_article)
    get :edit, params: { id: edition }
    assert_tab "Document", edit_admin_news_article_path(edition)
    assert_tab "Attachments", admin_edition_attachments_path(edition)
  end
end

class AttachableEditionsWithInlineSupportTest < ActionController::TestCase
  tests Admin::AttachmentsController

  setup { login_as :writer }

  view_test "GET :index lists the attachments with markdown hint for editions that support inline attachments" do
    edition = create(:news_article, :with_file_attachment)
    get :index, params: { edition_id: edition }
    attachment = edition.attachments.first

    assert_select "li", text: %r{#{attachment.title}}
    assert_select "input", value: "[InlineAttachment: 1]"
  end
end

class AttachableEditionWithoutInlineSupportTest < ActionController::TestCase
  tests Admin::AttachmentsController

  setup { login_as :writer }

  view_test "GET :index does not list the attachments for editions that do not support inline attachments" do
    edition = create(:publication, :with_file_attachment)
    get :index, params: { edition_id: edition }
    attachment = edition.attachments.first

    assert_select "li", text: %r{#{attachment.title}}
    assert_select "input", count: 1 # just the input[type=file]
  end
end
