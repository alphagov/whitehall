class LinkCheckerApiReport < ApplicationRecord
  belongs_to :edition
  has_many :links,
           -> { order(ordering: :asc) },
           class_name: "LinkCheckerApiReport::Link",
           dependent: :destroy

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

  def self.create_noop_report(edition)
    CreateNoopBatchReport.new(edition).call
  end

  def self.create_in_progress_report(batch_report, edition)
    CreateFromBatchReport.new(batch_report, edition).call
  end

  def mark_report_as_completed(batch_report)
    UpdateFromBatchReport.new(self, batch_report).update
  end

  def completed?
    status == "completed"
  end

  def in_progress?
    !completed?
  end

  def has_problems?
    links.any? { |l| %w[caution broken danger].include?(l.status) }
  end

  def broken_links
    links.select { |l| l.status == "broken" }
  end

  def caution_links
    links.select { |l| l.status == "caution" }
  end

  def danger_links
    links.select { |l| l.status == "danger" }
  end
end
