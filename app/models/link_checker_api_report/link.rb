class LinkCheckerApiReport::Link < ApplicationRecord
  serialize :check_errors, coder: YAML, type: Array
  serialize :check_warnings, coder: YAML, type: Array

  belongs_to :report, class_name: "LinkCheckerApiReport"

  scope :status_ok, -> { where(status: "ok") }
  scope :created_three_months_ago, -> { where("created_at < ?", 3.months.ago) }
  scope :deletable, -> { status_ok.merge(created_three_months_ago) }

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
