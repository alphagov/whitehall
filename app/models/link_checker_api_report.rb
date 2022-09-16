class LinkCheckerApiReport < ApplicationRecord
  belongs_to :link_reportable, polymorphic: true
  has_many :links,
           -> { order(ordering: :asc) },
           class_name: "LinkCheckerApiReport::Link"

  scope :no_links,
        lambda {
          where(
            "
NOT EXISTS (
  SELECT 1
  FROM link_checker_api_report_links
  WHERE link_checker_api_report_id = link_checker_api_reports.id
)",
          )
        }

  def self.create_noop_report(link_reportable)
    create!(
      batch_id: nil,
      completed_at: Time.zone.now,
      link_reportable:,
      status: "completed",
    )
  end

  def self.create_from_batch_report(batch_report, link_reportable)
    CreateFromBatchReport.new(batch_report, link_reportable).call
  end

  def update_from_batch_report(batch_report)
    UpdateFromBatchReport.new(self, batch_report).update
  end

  def completed?
    status == "completed"
  end

  def in_progress?
    !completed?
  end

  def has_problems?
    links.any? { |l| %w[caution broken].include?(l.status) }
  end

  def broken_links
    links.select { |l| l.status == "broken" }
  end

  def caution_links
    links.select { |l| l.status == "caution" }
  end
end
