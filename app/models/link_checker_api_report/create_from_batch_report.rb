class LinkCheckerApiReport::CreateFromBatchReport
  def initialize(payload, edition)
    @payload = payload
    @edition = edition
  end

  def call
    ActiveRecord::Base.transaction do
      delete_previous_reports
      report = create_report
      create_links(report)
      report
    end
  end

private

  attr_reader :payload, :edition

  def delete_previous_reports
    LinkCheckerApiReport
      .where(edition: edition)
      .map(&:destroy)
  end

  def create_report
    LinkCheckerApiReport.create!(
      batch_id:,
      **link_report_attributes,
    )
  end

  def create_links(report)
    payload.fetch("links", []).each_with_index do |link_payload, index|
      report.links.create!(
        link_attributes_from_report(link_payload, index),
      )
    end
  end

  def link_attributes_from_report(payload, index)
    LinkCheckerApiReport::Link
      .attributes_from_link_report(payload)
      .merge(ordering: index)
  end

  def link_report_attributes
    {
      completed_at: payload.fetch("completed_at"),
      edition:,
      status: payload.fetch("status"),
    }
  end

  def batch_id
    payload.fetch("id")
  end
end
