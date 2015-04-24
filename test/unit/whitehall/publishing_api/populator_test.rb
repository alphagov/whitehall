require 'whitehall/publishing_api'

module Whitehall
  class PublishingApi
    class PopulatorTest < ActiveSupport::TestCase

      test "calls the sender for each item" do
        items = [stub("edition")]
        sender = stub("sender")
        sender.expects(:call).with(items.first)
        Populator.new(items: items, sender: sender).call
      end

      test "logs each 1000 items" do
        items = (1..1001).to_a + ["a string"]
        logger = stub("logger")
        logger.expects(:info).with("Exporting items of class 'Fixnum'...")
        logger.expects(:info).with("done 1000...")
        logger.expects(:info).with("Exporting items of class 'String'...")
        logger.expects(:info).with("Finished.")

        Populator.new(items: items, sender: ->(_) {}, logger: logger).call
      end

      test "logs a new header when base class changes" do
        items = [build(:case_study), build(:publication), build(:news_article)]
        items << build(:organisation)
        logger = stub("logger")
        logger.expects(:info).with("Exporting items of class 'Edition'...")
        logger.expects(:info).with("Exporting items of class 'Organisation'...")
        logger.expects(:info).with("Finished.")

        Populator.new(items: items, sender: ->(_) {}, logger: logger).call
      end
    end
  end
end
