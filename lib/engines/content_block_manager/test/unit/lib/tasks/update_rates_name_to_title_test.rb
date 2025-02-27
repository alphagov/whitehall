require "test_helper"
require "rake"

class UpdateRatesNameToTitleTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown do
    Rake::Task["content_block_manager:change_rates_name"].reenable
  end

  let(:schema) { build(:content_block_schema, block_type: "content_block_pension", body: {}) }

  before do
    ContentBlockManager::ContentBlock::Schema.expects(:find_by_block_type).returns(schema).at_least_once
  end

  it "updates the rate names" do
    document = create(:content_block_document, :pension)

    edition_1 = create(:content_block_edition, document:, title: "Edition 1", details: {
      "description": "Edition 1",
      "rates": {
        "rate1":
          { "name": "rate1", "amount": "£100.5", "frequency": "a week", "description": "" },
      },
    })

    document_2 = create(:content_block_document, :pension)

    edition_2 = create(:content_block_edition, document: document_2, title: "Edition 4", details: {
      "description": "Edition 4",
      "rates": {
        "rate1":
          { "name": "rate1", "amount": "£100.5", "frequency": "a week", "description": "" },
        "rate2":
          { "name": "rate2", "amount": "£100.5", "frequency": "a month", "description": "" },
      },
    })

    Rake.application.invoke_task("content_block_manager:change_rates_name")

    assert_equal "rate1", edition_1.reload.details.dig("rates", "rate1", "title")
    assert_nil edition_1.reload.details.dig("rates", "rate1", "name")

    assert_equal "rate1", edition_2.reload.details.dig("rates", "rate1", "title")
    assert_equal "rate2", edition_2.reload.details.dig("rates", "rate2", "title")
    assert_nil edition_2.reload.details.dig("rates", "rate1", "name")
    assert_nil edition_2.reload.details.dig("rates", "rate2", "name")
  end
end
