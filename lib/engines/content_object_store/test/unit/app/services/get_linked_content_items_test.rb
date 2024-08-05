require "test_helper"

class ContentObjectStore::GetLinkedContentItemsTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:organisations) { 5.times.map { build(:organisation, content_id: SecureRandom.uuid) } }
  let(:response) do
    {
      "total" => 100,
      "pages" => 10,
      "current_page" => 1,
      "results" => [
        "title" => "foo",
        "base_path" => "/foo",
        "document_type" => "something",
        "links" => {},
        "link_set_links" => {},
      ],
    }
  end
  let(:content_block_document) { build(:content_block_document) }
  let(:publishing_api_mock) { MiniTest::Mock.new }

  setup do
    Services.publishing_api.stubs(:get_content_items).returns(response)
    Organisation.stubs(:where).returns(organisations)
  end

  describe "#items" do
    it "returns items correctly when items do not have an associated organisation" do
      result = ContentObjectStore::GetLinkedContentItems.new(content_block_document:, page: 1).items

      assert_equal result[0].title, response["results"][0]["title"]
      assert_equal result[0].base_path, response["results"][0]["base_path"]
      assert_equal result[0].document_type, response["results"][0]["document_type"]
      assert_equal result[0].organisation, nil
    end

    it "returns items correctly when items have an associated organisation in the links response" do
      response["results"][0]["links"] = {
        "primary_publishing_organisation" => [
          organisations.first.content_id,
        ],
      }

      result = ContentObjectStore::GetLinkedContentItems.new(content_block_document:, page: 1).items

      assert_equal result[0].title, response["results"][0]["title"]
      assert_equal result[0].base_path, response["results"][0]["base_path"]
      assert_equal result[0].document_type, response["results"][0]["document_type"]
      assert_equal result[0].organisation, organisations.first
    end

    it "returns items correctly when items have an associated organisation in the link_set_links response" do
      response["results"][0]["link_set_links"] = {
        "primary_publishing_organisation" => [
          organisations.first.content_id,
        ],
      }

      result = ContentObjectStore::GetLinkedContentItems.new(content_block_document:, page: 1).items

      assert_equal result[0].title, response["results"][0]["title"]
      assert_equal result[0].base_path, response["results"][0]["base_path"]
      assert_equal result[0].document_type, response["results"][0]["document_type"]
      assert_equal result[0].organisation, organisations.first
    end

    it "calls the client with the expected arguments" do
      ContentObjectStore::GetLinkedContentItems.new(content_block_document:, page: 1).items
    end
  end

  describe "#page_data" do
    it "returns page data" do
      result = ContentObjectStore::GetLinkedContentItems.new(content_block_document:, page: 1).page_data

      assert_equal result.total_items, response["total"]
      assert_equal result.total_pages, response["pages"]
      assert_equal result.current_page, response["current_page"]
    end
  end

  describe "#arguments" do
    it "generates the correct arguments" do
      result = ContentObjectStore::GetLinkedContentItems.new(content_block_document:, page: nil).arguments

      assert_equal result, {
        "link_embed" => content_block_document.content_id,
        "fields" => ContentObjectStore::GetLinkedContentItems::API_FIELDS,
        "page" => 1,
      }
    end

    it "generates the correct arguments with a page number" do
      result = ContentObjectStore::GetLinkedContentItems.new(content_block_document:, page: 2).arguments

      assert_equal result, {
        "link_embed" => content_block_document.content_id,
        "fields" => ContentObjectStore::GetLinkedContentItems::API_FIELDS,
        "page" => 2,
      }
    end
  end
end
