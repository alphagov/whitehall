class LinksReport < ActiveRecord::Base
  serialize :links, Array
  serialize :broken_links, Array

  belongs_to :link_reportable, polymorphic: true

  def self.from_record(record)
    create!(link_reportable: record, links: MarkdownLinkExtractor.new(record.body).links)
  end

  def completed?
    completed_at.present?
  end
end
