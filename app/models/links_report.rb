class LinksReport < ApplicationRecord
  serialize :links, Array
  serialize :broken_links, Array

  belongs_to :link_reportable, polymorphic: true

  def self.queue_for!(record)
    links = Govspeak::Document.new(record.body).extracted_links(website_root: website_root)

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

  def self.website_root
    @website_root ||= Plek.new.website_root
  end

  private_class_method :website_root
end
