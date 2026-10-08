require "test_helper"

class DocumentTypesConcernTest < ActiveSupport::TestCase
  class DummyContext
    include DocumentTypesConcern
    include Rails.application.routes.url_helpers

    attr_accessor :current_user, :user_can, :params

    def can?(_action, _subject)
      user_can
    end
  end

  setup do
    @context = DummyContext.new
    @context.current_user = build(:writer)
    @context.user_can = true
    @context.params = {}

    StandardEdition.stubs(:enforcer).with(@context.current_user).returns(stub(can?: true))
    ConfigurableDocumentType.stubs(:find).with("basic_page").returns({})
    ConfigurableDocumentType.stubs(:find).with("mini_site_child").returns({})
    Flipflop.stubs(:enabled?).with(:configurable_document_types).returns(true)
  end

  basic_document_type = {
    "klass" => StandardEdition,
    "hint_text" => "A standard ed",
    "label" => "Standard Edition",
    "configurable_document_type" => "basic_page",
  }

  basic_configurable_document_config = {
    "schema" => {},
    "settings" => { "images" => { "enabled" => false } },
    "forms" => { "documents" => { "fields" => {} } },
  }

  test "#valid_document_type? returns true for document types createable by the user" do
    StandardEdition.stubs(:enforcer).returns(stub(can?: true))
    assert @context.valid_document_type?("basic_page", basic_document_type)
  end

  test "#valid_document_type? returns false for document types not createable by the user" do
    StandardEdition.stubs(:enforcer).returns(stub(can?: false))
    assert_not @context.valid_document_type?("basic_page", basic_document_type)
  end

  test "#valid_document_type? returns false for *legacy* document types not createable by the user" do
    Publication.stubs(:enforcer).returns(stub(can?: false))
    assert_not @context.valid_document_type?("basic_page", basic_document_type.merge("klass" => Publication))
  end

  test "#valid_document_type? returns true for document types the user has access to" do
    @context.user_can = true
    assert @context.valid_document_type?("basic_page", basic_document_type)
  end

  test "#valid_document_type? returns false for document types the user does not have access to" do
    @context.user_can = false
    assert_not @context.valid_document_type?("basic_page", basic_document_type)
  end

  test "#valid_document_type? does not look up a configurable document type for *legacy* document types" do
    Publication.stubs(:enforcer).returns(stub(can?: true))
    ConfigurableDocumentType.expects(:find).never

    assert @context.valid_document_type?("publication", basic_document_type.except("configurable_document_type").merge("klass" => Publication))
  end

  test "#valid_document_type? returns true when the specified feature flag is enabled" do
    Flipflop.stubs(:enabled?).with(:configurable_document_types).returns(true)
    feature_flagged_document_type = basic_document_type.merge("requires_feature_flag" => :configurable_document_types)

    assert @context.valid_document_type?("basic_page", feature_flagged_document_type)
  end

  test "#valid_document_type? returns false when the specified feature flag is enabled" do
    Flipflop.stubs(:enabled?).with(:configurable_document_types).returns(false)
    feature_flagged_document_type = basic_document_type.merge("requires_feature_flag" => :configurable_document_types)

    assert_not @context.valid_document_type?("basic_page", feature_flagged_document_type)
  end

  test "#valid_document_type? returns true when the specified feature flag is not required" do
    Flipflop.stubs(:enabled?).with(:configurable_document_types).returns(false)
    assert @context.valid_document_type?("basic_page", basic_document_type) # doesn't specify a required feature flag
  end

  test "#valid_document_type? returns true when the document type does not require a parent and no parent is specified" do
    document_type = basic_document_type.merge("requires_parent" => false)
    @context.params = {}
    assert @context.valid_document_type?("basic_page", document_type)
  end

  test "#valid_document_type? returns false when the document type does require a parent but no parent is specified" do
    child_document_type = basic_document_type.merge("requires_parent" => true)
    @context.params = {}
    assert_not @context.valid_document_type?("basic_page", child_document_type)
  end

  test "#valid_document_type? returns true when the document type does require a parent and a parent is specified" do
    parent_document_config = { "settings" => { "allowed_child_document_types" => [{ "document_type" => "mini_site_child" }] } }
    ConfigurableDocumentType.stubs(:find).with("test_type")
      .returns(ConfigurableDocumentType.new(basic_configurable_document_config.deep_merge(parent_document_config)))

    edition = create(:standard_edition, configurable_document_type: "test_type")
    @context.params = { parent_edition_id: edition.id }

    child_document_type = basic_document_type.merge("requires_parent" => true)

    assert @context.valid_document_type?("mini_site_child", child_document_type)
  end

  test "#valid_document_type? returns false when the document type does not require a parent and a parent is specified" do
    parent_document_config = { "settings" => { "allowed_child_document_types" => [] } }
    ConfigurableDocumentType.stubs(:find).with("test_type")
      .returns(ConfigurableDocumentType.new(basic_configurable_document_config.deep_merge(parent_document_config)))

    edition = create(:standard_edition, configurable_document_type: "test_type")
    @context.params = { parent_edition_id: edition.id }

    child_document_type = basic_document_type.merge("requires_parent" => false)

    assert_not @context.valid_document_type?("mini_site_child", child_document_type)
  end

  test "#valid_document_type? returns false when called with a parent edition ID which is not a standard edition" do
    edition = create(:publication)
    @context.params = { parent_edition_id: edition.id }

    child_document_type = basic_document_type.merge("requires_parent" => false)

    assert_not @context.valid_document_type?("mini_site_child", child_document_type)
  end

  test "#standard_document_types returns a hash of document type hashes" do
    ConfigurableDocumentType.stubs(:find).returns(ConfigurableDocumentType.new({}))
    assert @context.standard_document_types.is_a?(Hash)

    @context.standard_document_types.each do |document_type_key, document_type|
      assert document_type_key.is_a?(String)
      assert document_type.is_a?(Hash)
      assert document_type.key?("klass")
      assert document_type.key?("hint_text")
      assert document_type.key?("label")
    end
  end

  test "#requires_approval_document_types returns a hash of document type hashes" do
    ConfigurableDocumentType.stubs(:find).returns(ConfigurableDocumentType.new({}))
    assert @context.requires_approval_document_types.is_a?(Hash)

    @context.requires_approval_document_types.each do |document_type_key, document_type|
      assert document_type_key.is_a?(String)
      assert document_type.is_a?(Hash)
      assert document_type.key?("klass")
      assert document_type.key?("hint_text")
      assert document_type.key?("label")
    end
  end

  test "#permitted_document_types returns the union of the standard document types and the document types which require approval" do
    ConfigurableDocumentType.stubs(:find).returns(ConfigurableDocumentType.new({}))
    assert_equal @context.permitted_document_types, @context.standard_document_types.merge(@context.requires_approval_document_types)
  end

  test "#document_type_redirect returns nil when the document type has no redirect" do
    assert_nil @context.document_type_redirect(basic_document_type)
  end

  test "#document_type_redirect simply reads the redirect property of the document type" do
    document_type_with_redirect = basic_document_type.merge("redirect" => "/government/admin/foo")

    assert_equal "/government/admin/foo",
                 @context.document_type_redirect(document_type_with_redirect)
  end
end
