require 'test_helper'

class Admin::DocumentSourcesControllerTest < ActionController::TestCase
  setup do
    login_as :importer
  end

  should_be_an_admin_controller

  test "update should add a document source" do
    edition = create(:draft_policy)

    put :update, edition_id: edition, document_sources: "http://woo.example.com"

    refute edition.document.document_sources.empty?
    assert_equal 1, edition.document.document_sources.size
    assert_equal "http://woo.example.com", edition.document.document_sources.first.url
    assert_redirected_to admin_policy_path(edition, anchor: 'document-sources')
  end

  test "update should remove a document source" do
    edition = create(:draft_policy)
    document_source = edition.document.document_sources.create(url: 'http://www.example.com/')

    put :update, edition_id: edition, document_sources: ""

    edition.document.document_sources.reload
    assert edition.document.document_sources.empty?
    assert_equal 0, edition.document.document_sources.size
    assert_raise ActiveRecord::RecordNotFound do
      document_source.reload
    end
    assert_redirected_to admin_policy_path(edition, anchor: 'document-sources')
  end

  test "update should add multiple document sources" do
    edition = create(:draft_policy)

    put :update, edition_id: edition, document_sources: %Q{http://www.example.com
http://woo.example.com}

    refute edition.document.document_sources.empty?
    assert_equal 2, edition.document.document_sources.size
    assert_equal ["http://www.example.com", "http://woo.example.com"], edition.document.document_sources.map(&:url)
    assert_redirected_to admin_policy_path(edition, anchor: 'document-sources')
  end

  test "update should not duplicate existing document sources" do
    edition = create(:draft_policy)
    edition.document.document_sources.create(url: 'http://www.example.com/')

    put :update, edition_id: edition, document_sources: %Q{http://www.example.com
http://woo.example.com}

    edition.document.document_sources.reload
    refute edition.document.document_sources.empty?
    assert_equal 2, edition.document.document_sources.size
    assert_equal ["http://www.example.com", "http://woo.example.com"], edition.document.document_sources.map(&:url)
    assert_redirected_to admin_policy_path(edition, anchor: 'document-sources')
  end

end
