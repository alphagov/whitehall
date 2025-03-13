class LinkCheckerApiReport::CreateNoopBatchReport
  def initialize(edition)
    @edition = edition
  end

  def call
    LinkCheckerApiReport.create!(
      batch_id: nil,
      completed_at: Time.zone.now,
      edition:,
      status: "completed",
    )
  end

private

  attr_reader :edition
end
