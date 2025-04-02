class LinkCheckReportValidator < ActiveModel::Validator
  def validate(edition)
    if contains_dangerous_links?(edition)
      edition.errors.add(
        :base,
        "This document has not been published. You need to remove dangerous links before publishing.".html_safe,
      )
    end
  end

private

  def contains_dangerous_links?(edition)
    edition.link_check_report.present? && edition.link_check_report.danger_links.any?
  end
end
