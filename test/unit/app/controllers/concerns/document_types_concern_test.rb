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


  test "#document_type_redirect returns nil when the document type has no redirect" do
    assert_nil @context.document_type_redirect(basic_document_type)
  end

  test "#document_type_redirect simply reads the redirect property of the document type" do
    document_type_with_redirect = basic_document_type.merge("redirect" => "/government/admin/foo")

    assert_equal "/government/admin/foo",
                 @context.document_type_redirect(document_type_with_redirect)
  end
end
