class LinkCheckerApiReport::CreateNoopBatchReport
  def initialize(edition)
    @edition = edition
  end

  def call
    ActiveRecord::Base.transaction do
      delete_previous_reports
      LinkCheckerApiReport.create!(
        batch_id: nil,
        completed_at: Time.zone.now,
        edition:,
        status: "completed",
      )
    end
  end

private

  attr_reader :edition

  def delete_previous_reports
    LinkCheckerApiReport
      .where(edition: edition)
      .map(&:destroy)
  end
end
