require "test_helper"

class ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:helper_mock) { mock }

  before do
    ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponent.any_instance.stubs(:helpers).returns(helper_mock)
    helper_mock.stubs(:content_block_manager).returns(helper_mock)
    helper_mock.stubs(:content_block_manager_content_block_documents_path).returns("path")
    helper_mock.stubs(:content_block_manager_root_path).returns("path")

    helper_mock.stubs(:taggable_organisations_container).returns([
      { text: "Department of Placeholder", value: 1 },
      { text: "Ministry of Example", value: 2 },
    ])

    ContentBlockManager::ContentBlock::Schema.stubs(:valid_schemas).returns(%w[pension contact])
  end

  it "expands all sections by default" do
    render_inline(
      ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponent.new(
        filters: {},
      ),
    )
    assert_selector ".govuk-accordion__section--expanded", count: 4
  end

  it "adds value of keyword to text input from filter" do
    render_inline(
      ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponent.new(
        filters: { keyword: "ministry defense" },
      ),
    )

    assert_selector ".govuk-accordion__section--expanded", text: "Keyword"
    assert_selector "input[name='keyword'][value='ministry defense']"
  end

  it "renders checkbox items for all valid schemas" do
    render_inline(
      ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponent.new(
        filters: {},
      ),
    )

    assert_selector "input[type='checkbox'][name='block_type[]'][value='pension']"
    assert_selector "input[type='checkbox'][name='block_type[]'][value='contact']"
  end

  it "checks checkbox items if checked in filters" do
    render_inline(
      ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponent.new(
        filters: { block_type: %w[pension] },
      ),
    )

    assert_selector ".govuk-accordion__section--expanded", text: "Content block type"

    assert_selector "input[type='checkbox'][name='block_type[]'][value='pension'][checked]"
    assert_selector "input[type='checkbox'][name='block_type[]'][value='contact']"
  end

  it "returns organisations with an 'all organisations' option" do
    render_inline(ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponent.new(filters: {}))

    assert_selector "select[name='lead_organisation']"
    assert_selector "option[selected='selected'][value='']"
  end

  it "selects organisation if selected in filters" do
    helper_mock.stubs(:taggable_organisations_container).returns([
      { text: "Department of Placeholder", value: 1 },
      { text: "Ministry of Example", value: 2, selected: true },
    ])
    render_inline(
      ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponent.new(
        filters: { lead_organisation: "2" },
      ),
    )

    assert_selector ".govuk-accordion__section--expanded", text: "Lead organisation"

    assert_selector "select[name='lead_organisation']"
    assert_selector "option[selected='selected'][value=2]"
  end

  it "passes filters and errors to Date component" do
    filters = { lead_organisation: "2" }
    errors = [
      ContentBlockManager::ContentBlock::Document::DocumentFilter::FILTER_ERROR.new(
        attribute: "last_updated_from", full_message: "From date is not in the correct format",
      ),
    ]
    date_component = ContentBlockManager::ContentBlock::Document::Index::DateFilterComponent.new(filters:, errors:)
    ContentBlockManager::ContentBlock::Document::Index::DateFilterComponent.expects(:new).with(filters:, errors:)
                                                                           .returns(date_component)

    render_inline(
      ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponent.new(
        filters:,
        errors:,
      ),
    )

    assert_selector ".govuk-accordion__section--expanded", text: "Last updated date"
  end
end
