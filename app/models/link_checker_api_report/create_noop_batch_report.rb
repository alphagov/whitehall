class LinkCheckerApiReport::CreateNoopBatchReport
  def initialize(edition)
    @edition = edition
  end

  def call
    ActiveRecord::Base.transaction do
      lock_edition
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

  # Serialise concurrent jobs for the same edition, otherwise both can miss
  # each other's report when deleting and then violate the unique edition_id index.
  def lock_edition
    Edition.where(id: edition.id).lock.pluck(:id)
  end

  def delete_previous_reports
    LinkCheckerApiReport
      .where(edition: edition)
      .map(&:destroy)
  end
end
