class LinksReportWorker < WorkerBase
  def perform(id)
    links_report = LinksReport.find(id)
    link_checker = LinksChecker.new(links_report.links)
    link_checker.run

    links_report.broken_links = link_checker.broken_links
    links_report.completed_at = Time.zone.now
    links_report.save!
  end
end
