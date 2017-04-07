class LinkCheckerApiReport::CreateFromBatchReport
  def initialize(payload, link_reportable)
    @payload = payload
    @link_reportable = link_reportable
  end

  def create
    report = create_report
    create_links(report)
    report
  end

private

  attr_reader :payload, :link_reportable

  def create_report
    LinkCheckerApiReport.create!(
      batch_id: payload.fetch("id"),
      completed_at: payload.fetch("completed_at"),
      link_reportable: link_reportable,
      status: payload.fetch("status"),
    )
  end

  def create_links(report)
    payload.fetch("links", []).each_with_index do |link_payload, index|
      attributes = LinkCheckerApiReport::Link
        .attributes_from_link_report(link_payload)
        .merge(ordering: index)

      report.links.create!(attributes)
    end
  end
end
