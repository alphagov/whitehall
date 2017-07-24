class LinkCheckerApiReport < ActiveRecord::Base
  belongs_to :link_reportable, polymorphic: true
  has_many :links,
           -> { order(ordering: :asc) },
           class_name: LinkCheckerApiReport::Link

  def self.create_from_batch_report(batch_report, link_reportable)
    CreateFromBatchReport.new(batch_report, link_reportable).create
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
    links.any? { |l| %w(caution broken).include?(l.status) }
  end

  def broken_links
    links.select { |l| l.status == "broken" }
  end

  def caution_links
    links.select { |l| l.status == "caution" }
  end
end
