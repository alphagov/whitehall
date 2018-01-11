class LinkCheckerApiReport::CreateFromBatchReport
  def initialize(payload, reportable)
    @payload = payload
    @reportable = reportable
  end

  def create
    ActiveRecord::Base.transaction do
      report = replace_or_create_report
      create_links(report)
      report
    end
  end

private

  attr_reader :payload, :reportable

  def replace_or_create_report
    begin
      replace_report
    rescue ActiveRecord::RecordNotFound
      create_report
    end
  end

  def replace_report
    report = LinkCheckerApiReport.find_by!(batch_id: batch_id)
    report.links.delete_all
    report.update!(link_report_attributes)
    report
  end

  def create_report
    LinkCheckerApiReport.create!(
      batch_id: batch_id,
      **link_report_attributes,
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

  def link_report_attributes
    {
      completed_at: payload.fetch("completed_at"),
      link_reportable: reportable,
      status: payload.fetch("status"),
    }
  end

  def batch_id
    payload.fetch("id")
  end
end
