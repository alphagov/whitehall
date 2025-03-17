module Edition::Scopes::FilterableByBrokenLinks
  extend ActiveSupport::Concern

  included do
    scope :only_broken_links, lambda {
      joins(
        "
  LEFT JOIN (
    SELECT id, edition_id
    FROM link_checker_api_reports
    GROUP BY edition_id
    ORDER BY id DESC
  ) AS latest_link_checker_api_reports
    ON latest_link_checker_api_reports.edition_id = editions.id
   AND latest_link_checker_api_reports.id = (SELECT MAX(id) FROM link_checker_api_reports WHERE link_checker_api_reports.edition_id = editions.id)",
      ).where(
        "
  EXISTS (
    SELECT 1
    FROM link_checker_api_report_links
    WHERE link_checker_api_report_id = latest_link_checker_api_reports.id
      AND link_checker_api_report_links.status IN ('danger', 'broken', 'caution')
  )",
      )
    }
  end
end
