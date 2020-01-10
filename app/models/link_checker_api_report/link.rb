class LinkCheckerApiReport::Link < ApplicationRecord
  serialize :check_errors, Array
  serialize :check_warnings, Array

  belongs_to :report, class_name: "LinkCheckerApiReport"

  scope :status_ok, -> { where(status: "ok") }
  scope :created_six_months_ago, -> { where("created_at < ?", 6.months.ago) }
  scope :deletable, -> { self.status_ok.merge(self.created_six_months_ago) }

  def self.attributes_from_link_report(payload)
    {
      uri: payload.fetch("uri"),
      status: payload.fetch("status"),
      checked: payload.fetch("checked"),
      check_warnings: payload.fetch("warnings", []),
      check_errors: payload.fetch("errors", []),
      problem_summary: payload.fetch("problem_summary"),
      suggested_fix: payload.fetch("suggested_fix"),
    }
  end
end
