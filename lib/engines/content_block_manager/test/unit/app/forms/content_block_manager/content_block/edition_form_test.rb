require "test_helper"

class ContentBlockManager::ContentBlock::EditionFormTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  include ContentBlockManager::Engine.routes.url_helpers

  let(:schema) { build(:content_block_schema, :pension, body: { "properties" => { "foo" => "", "bar" => "" } }) }
  let(:result) do
    ContentBlockManager::ContentBlock::EditionForm.for(
      content_block_edition:,
      schema:,
    )
  end

  describe "when initialized for an edition with an existing document and live edition" do
    let(:content_block_document) { build(:content_block_document, :pension, id: 123, latest_edition_id: "5b271577-3d3d-475d-986a-246d8c4063a3") }
    let(:content_block_edition) { build(:content_block_edition, :pension, document: content_block_document) }

    let(:result) do
      ContentBlockManager::ContentBlock::EditionForm.for(
        content_block_edition:,
        schema:,
      )
    end

    it "initializes with the correct attributes from the schema" do
      expected_attributes = { "foo" => nil, "bar" => nil }

      assert_equal content_block_edition, result.content_block_edition
      assert_equal schema, result.schema
      assert_equal expected_attributes, result.attributes
    end

    it "sets the correct title" do
      assert_equal I18n.t("content_block_edition.update.title", block_type: "pension"), result.title
    end

    it "sets the correct urls" do
      assert_equal content_block_manager_content_block_document_path(id: content_block_edition.document.id), result.back_path
      assert_equal content_block_manager_content_block_document_editions_path(document_id: content_block_edition.document.id), result.url
    end

    it "sets the correct form method" do
      assert_equal :post, result.form_method
    end

    describe "when the errors include a sluggable_string error" do
      before do
        content_block_document.sluggable_string = nil
        content_block_edition.title = nil
        content_block_edition.valid?
      end

      it "removes the error from the object" do
        assert_equal 1, result.content_block_edition.errors.count
        assert_not_includes result.content_block_edition.errors.map(&:attribute), "document.sluggable_string".to_sym
      end
    end
  end

  describe "when initialized for an edition without an existing document" do
    let(:content_block_edition) { build(:content_block_edition, :pension, document: nil) }

    let(:result) do
      ContentBlockManager::ContentBlock::EditionForm.for(
        content_block_edition:,
        schema:,
      )
    end

    it "initializes with the correct attributes from the schema" do
      expected_attributes = { "foo" => nil, "bar" => nil }

      assert_equal content_block_edition, result.content_block_edition
      assert_equal schema, result.schema
      assert_equal expected_attributes, result.attributes
    end

    it "sets the correct title" do
      assert_equal I18n.t("content_block_edition.create.title", block_type: "pension"), result.title
    end

    it "sets the correct urls" do
      assert_equal new_content_block_manager_content_block_document_path, result.back_path
      assert_equal content_block_manager_content_block_editions_path, result.url
    end

    it "sets the correct form method" do
      assert_equal :post, result.form_method
    end

    describe "when the errors include a sluggable_string error" do
      before do
        content_block_edition.title = nil
        content_block_edition.document = build(:content_block_document, :pension, sluggable_string: nil)
        content_block_edition.valid?
      end

      it "removes the error from the object" do
        assert_equal 1, result.content_block_edition.errors.count
        assert_not_includes result.content_block_edition.errors.map(&:attribute), "document.sluggable_string".to_sym
      end
    end
  end

  describe "edit form" do
    let(:content_block_document) { build_stubbed(:content_block_document, :pension) }
    let(:content_block_edition) { build_stubbed(:content_block_edition, :pension, document: content_block_document) }

    let(:result) do
      ContentBlockManager::ContentBlock::EditionForm::Edit.new(
        content_block_edition:,
        schema:,
      )
    end

    it "initializes with the correct attributes from the schema" do
      expected_attributes = { "foo" => nil, "bar" => nil }

      assert_equal content_block_edition, result.content_block_edition
      assert_equal schema, result.schema
      assert_equal expected_attributes, result.attributes
    end

    it "sets the correct title" do
      assert_equal I18n.t("content_block_edition.update.title", block_type: "pension"), result.title
    end

    it "sets the correct urls" do
      assert_equal content_block_manager_content_block_document_path(content_block_edition.document), result.back_path
      assert_equal content_block_manager_content_block_workflow_path(content_block_edition, step: "edit_draft"), result.url
    end

    it "sets the correct form method" do
      assert_equal :put, result.form_method
    end

    describe "when the errors include a sluggable_string error" do
      before do
        content_block_edition.title = nil
        content_block_edition.document = build(:content_block_document, :pension, sluggable_string: nil)
        content_block_edition.valid?
      end

      it "removes the error from the object" do
        assert_equal 1, result.content_block_edition.errors.count
        assert_not_includes result.content_block_edition.errors.map(&:attribute), "document.sluggable_string".to_sym
      end
    end
  end
end
