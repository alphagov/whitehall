class LinkCheckerApiReport::UpdateFromBatchReport
  def initialize(report, payload)
    @report = report
    @payload = payload
  end

  def update
    ActiveRecord::Base.transaction do
      update_report
      links = payload.fetch("links", [])
      delete_removed_links(links)
      update_links(links)
      # TODO: automatically remove bad link and republish edition if it is live
      # (probably best to do this here?)
      # UpdateFromBatchReport is called via `mark_report_as_completed`
      # which is called via the `LinkCheckerApiController` callback
    end
  end

private

  attr_reader :report, :payload

  def update_report
    report.update!(
      status: payload.fetch("status"),
      completed_at: payload.fetch("completed_at"),
    )
  end

  def delete_removed_links(links_payload)
    uris = links_payload.map { |l| l.fetch("uri") }
    to_delete = report.links.reject { |l| uris.include?(l.uri) }
    report.links.delete(to_delete)
  end

  def update_links(links_payload)
    links_payload.each_with_index do |link_payload, index|
      link = report.links.find { |l| l.uri == link_payload.fetch("uri") }

      attributes = link_attributes_from_report(link_payload, index)

      link ? link.update!(attributes) : report.links.create!(attributes)
    end
  end

  def link_attributes_from_report(payload, index)
    LinkCheckerApiReport::Link
      .attributes_from_link_report(payload)
      .merge(ordering: index)
  end
end
