require "test_helper"
require "content_publisher/document_collection_group_membership_migrator"

module ContentPublisher
  class DocumentCollectionGroupMembershipMigratorTest < ActiveSupport::TestCase
    test "update document collection group membership with non whitehall link" do
      edition = create(:published_news_article)
      document_collection_group_membership = create(:document_collection_group_membership, document: edition.document)

      ContentPublisher::DocumentCollectionGroupMembershipMigrator.new(document_collection_group_membership.document).call
      document_collection_group_membership.reload

      non_whitehall_link = document_collection_group_membership.non_whitehall_link

      assert_nil document_collection_group_membership.document_id
      assert_equal edition.title, non_whitehall_link.title
      assert_equal "/government/news/news-title", non_whitehall_link.base_path
      assert_equal "content-publisher", non_whitehall_link.publishing_app
    end

    test "uses the latest edition if document is not published" do
      edition = create(:news_article)
      document_collection_group_membership = create(:document_collection_group_membership, document: edition.document)

      ContentPublisher::DocumentCollectionGroupMembershipMigrator.new(document_collection_group_membership.document).call
      document_collection_group_membership.reload

      non_whitehall_link = document_collection_group_membership.non_whitehall_link

      assert_nil document_collection_group_membership.document_id
      assert_equal edition.title, non_whitehall_link.title
      assert_equal "/government/news/news-title", non_whitehall_link.base_path
      assert_equal "content-publisher", non_whitehall_link.publishing_app
    end

    test "do not create non whitehall link if document is not in document collection" do
      edition = create(:published_news_article)

      ContentPublisher::DocumentCollectionGroupMembershipMigrator.new(edition.document).call
      assert_equal 0, DocumentCollectionNonWhitehallLink.count
    end
  end
end
