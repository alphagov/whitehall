require "test_helper"
require "rake"

class UpdateRatesCadenceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown do
    Rake::Task["content_block_manager:update_rates_cadence"].reenable
  end

  let(:schema) { build(:content_block_schema, block_type: "content_block_pension", body: { }) }

  before do
    ContentBlockManager::ContentBlock::Schema.expects(:find_by_block_type).returns(schema).at_least_once
  end


  it "updates the rate cadences" do
    document = create(:content_block_document, :pension)

    edition_1 = create(:content_block_edition, document:, title: "Edition 1", details: {
      "description": "Edition 1",
      "rates": {
        "rate1":
          { "name": "rate1", "amount": "£100.5", "cadence": "weekly", "description": "" },
      },
    })

    edition_2 = create(:content_block_edition, document:, title: "Edition 2", details: {
      "description": "Edition 2",
      "rates": {
        "rate1":
          { "name": "rate3", "amount": "£100.5", "cadence": "monthly", "description": "" },
      },
    })

    document_2 = create(:content_block_document, :pension)

    edition_3 = create(:content_block_edition, document: document_2, title: "Edition 3", details: {
      "description": "Edition 3",
      "rates": {
        "rate1":
          { "name": "rate3", "amount": "£100.5", "cadence": "a month", "description": "" },
      },
    })

    edition_4 = create(:content_block_edition, document: document_2, title: "Edition 4", details: {
      "description": "Edition 4",
      "rates": {
        "rate1":
          { "name": "rate1", "amount": "£100.5", "cadence": "weekly", "description": "" },
        "rate2":
          { "name": "rate2", "amount": "£100.5", "cadence": "monthly", "description": "" },
      },
    })

    Rake.application.invoke_task("content_block_manager:update_rates_cadence")

    assert_equal "a week", edition_1.reload.details.dig("rates", "rate1", "cadence")
    assert_equal "a month", edition_2.reload.details.dig("rates", "rate1", "cadence")
    assert_equal "a month", edition_3.reload.details.dig("rates", "rate1", "cadence")
    assert_equal "a week", edition_4.reload.details.dig("rates", "rate1", "cadence")
    assert_equal "a month", edition_4.reload.details.dig("rates", "rate2", "cadence")
  end
end
