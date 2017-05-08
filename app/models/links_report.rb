class LinksReport < ApplicationRecord
  serialize :links, Array
  serialize :broken_links, Array

  belongs_to :link_reportable, polymorphic: true

  def self.queue_for!(record)
    links = Govspeak::LinkExtractor.new(record.body).links

    create!(link_reportable: record, links: links).tap do |links_report|
      LinksReportWorker.perform_async(links_report.id)
    end
  end

  def completed?
    completed_at.present?
  end

  def in_progress?
    !completed?
  end
end
