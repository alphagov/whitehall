require "test_helper"

class ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponentTest < ViewComponent::TestCase
  test "adds value of keyword to text input from filter" do
    render_inline(ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponent.new(
                    filters: { keyword: "ministry defense" },
                  ))

    assert_selector "input[name='keyword'][value='ministry defense']"
  end

  test "renders checkbox items for all valid schemas" do
    ContentBlockManager::ContentBlock::Schema.expects(:valid_schemas).returns(%w[email_address postal_address])
    render_inline(ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponent.new(
                    filters: {},
                  ))

    assert_selector "input[type='checkbox'][name='block_type[]'][value='email_address']"
    assert_selector "input[type='checkbox'][name='block_type[]'][value='postal_address']"
  end

  test "checks checkbox items if checked in filters" do
    ContentBlockManager::ContentBlock::Schema.expects(:valid_schemas).returns(%w[email_address postal_address])
    render_inline(ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponent.new(
                    filters: { block_type: %w[email_address] },
                  ))

    assert_selector "input[type='checkbox'][name='block_type[]'][value='email_address'][checked]"
    assert_selector "input[type='checkbox'][name='block_type[]'][value='postal_address']"
  end

  test "returns organisations with an 'all organisations' option" do
    helper_mock = mock
    ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponent.any_instance.stubs(:helpers).returns(helper_mock)
    helper_mock.stubs(:content_block_manager).returns(helper_mock)
    helper_mock.stubs(:content_block_manager_content_block_documents_path).returns("path")
    helper_mock.stubs(:taggable_organisations_container).returns(
      [["Department of Placeholder", 1], ["Ministry of Example", 2]],
    )
    render_inline(ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponent.new(filters: {}))

    assert_selector "select[name='lead_organisation']"
    assert_selector "option[selected='selected'][value='']"
  end

  test "selects organisation if selected in filters" do
    helper_mock = mock
    ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponent.any_instance.stubs(:helpers).returns(helper_mock)
    helper_mock.stubs(:content_block_manager).returns(helper_mock)
    helper_mock.stubs(:content_block_manager_content_block_documents_path).returns("path")
    helper_mock.stubs(:taggable_organisations_container).returns(
      [["Department of Placeholder", 1], ["Ministry of Example", 2]],
    )
    render_inline(ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponent.new(
                    filters: { lead_organisation: "2" },
                  ))

    assert_selector "select[name='lead_organisation']"
    assert_selector "option[selected='selected'][value=2]"
  end
end
