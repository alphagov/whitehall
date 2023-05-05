require "test_helper"

class Reports::PublishedAttachmentsReportTest < ActiveSupport::TestCase
  test "returns a report containing file attachments" do
    create(:published_detailed_guide, :with_file_attachment)

    Timecop.freeze do
      path = Rails.root.join("tmp/attachments_#{Time.zone.now.strftime('%d-%m-%Y_%H-%M')}.csv")

      capture_io do
        Reports::PublishedAttachmentsReport.new.report
      end

      assert_equal Reports::PublishedAttachmentsReport::CSV_HEADERS, CSV.read(path)[0]
      assert_equal 1, CSV.read(path, headers: true).count
    end
  end

  test "returns blank report if there are no eligible file attachments" do
    create(:detailed_guide, :with_file_attachment)

    Timecop.freeze do
      path = Rails.root.join("tmp/attachments_#{Time.zone.now.strftime('%d-%m-%Y_%H-%M')}.csv")

      capture_io do
        Reports::PublishedAttachmentsReport.new.report
      end

      assert_equal Reports::PublishedAttachmentsReport::CSV_HEADERS, CSV.read(path)[0]
      assert_equal 0, CSV.read(path, headers: true).count
    end
  end
end
