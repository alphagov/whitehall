require "test_helper"
require "capybara/rails"

class ContentBlockEditionsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  extend Minitest::Spec::DSL

  before do
    login_as_admin
  end

  describe "#index" do
    test "it returns all Content Block Editions" do
      content_block_document = create(:content_block_document)
      create(
        :content_block_edition,
        details: '"email_address":"example@example.com"',
        content_block_document_id: content_block_document.id,
      )
      visit "/government/admin/content-object-store/content-block-editions"
      assert_text '"email_address":"example@example.com"'
    end
  end

  describe "#new" do
    test "it shows a list of all the valid block types" do
      schemas = [
        ContentObjectStore::Schema.new("content_block_foo", { "properties" => { "foo" => {}, "bar" => {} } }),
        ContentObjectStore::Schema.new("content_block_bar", { "properties" => { "foo" => {}, "bar" => {} } }),
      ]

      given_there_are_existing_schemas schemas
      and_i_access_the_create_new_object_page
      then_i_should_see_all_the_schemas_listed schemas
      when_i_click_on_a_schema schemas[0]
      then_i_should_see_a_form schemas[0]
      when_i_complete_the_form "My title", { "foo" => "Foo text", "bar" => "Bar text" }
      then_the_edition_should_have_been_created_successfully schemas[0], "My title", { "foo" => "Foo text", "bar" => "Bar text" }
    end
  end

private

  def given_there_are_existing_schemas(schemas)
    ContentObjectStore::SchemaService.expects(:valid_schemas).returns(schemas)
  end

  def and_i_access_the_create_new_object_page
    visit "/government/admin/content-object-store/content-block-editions/new"
  end

  def then_i_should_see_all_the_schemas_listed(schemas)
    schemas.each do |schema|
      assert_text schema.name
    end
  end

  def when_i_click_on_a_schema(schema)
    ContentObjectStore::SchemaService.expects(:schema_for_block_type).with("foo").at_least_once.returns(schema)
    click_on(schema.name)
  end

  def then_i_should_see_a_form(schema)
    assert_text "Create #{schema.name}"
  end

  def when_i_complete_the_form(title, details)
    fill_in "Title", with: title
    details.keys.each do |k|
      fill_in "content_object_store_content_block_edition_details_#{k}", with: details[k]
    end
    click_on "Save and continue"
  end

  def then_the_edition_should_have_been_created_successfully(schema, title, details)
    assert_text "#{schema.name} created successfully"

    edition = ContentObjectStore::ContentBlockEdition.all.last

    assert_not_nil edition
    assert_not_nil edition.document

    assert_equal edition.title, title
    details.keys.each do |k|
      assert_equal edition.details[k], details[k]
    end
  end
end
