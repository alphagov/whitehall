require "test_helper"

class ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponentTest < ViewComponent::TestCase
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
end
