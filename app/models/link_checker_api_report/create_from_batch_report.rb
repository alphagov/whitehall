class LinkCheckerApiReport::CreateFromBatchReport
  def initialize(payload, edition)
    @payload = payload
    @edition = edition
  end

  def call
    ActiveRecord::Base.transaction do
      report = replace_or_create_report
      create_links(report)
      report
    end
  end

private

  attr_reader :payload, :edition

  def replace_or_create_report
    replace_report
  rescue ActiveRecord::RecordNotFound
    create_report
  end

  def replace_report
    report = LinkCheckerApiReport.find_by!(batch_id:)
    report.links.delete_all
    report.update!(link_report_attributes)
    report
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
      link_reportable: edition, # TODO: remove this line
      status: payload.fetch("status"),
    }
  end

  def batch_id
    payload.fetch("id")
  end
end
