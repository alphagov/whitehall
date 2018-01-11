class LinkCheckerApiReport::CreateFromBatchReport
  def initialize(payload, reportable)
    @payload = payload
    @reportable = reportable
  end

  def create
    ActiveRecord::Base.transaction do
      report = create_report
      create_links(report)
      report
    end
  end

private

  attr_reader :payload, :reportable

  def create_report
    LinkCheckerApiReport.create!(
      batch_id: payload.fetch("id"),
      completed_at: payload.fetch("completed_at"),
      link_reportable: reportable,
      status: payload.fetch("status"),
    )
  end

  def create_links(report)
    payload.fetch("links", []).each_with_index do |link_payload, index|
      report.links.create!(
        link_attributes_from_report(link_payload, index)
      )
    end
  end

  def link_attributes_from_report(payload, index)
    LinkCheckerApiReport::Link
      .attributes_from_link_report(payload)
      .merge(ordering: index)
  end
end
