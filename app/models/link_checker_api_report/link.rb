class LinkCheckerApiReport::Link < ApplicationRecord
  serialize :check_dangers, coder: YAML, type: Array
  serialize :check_errors, coder: YAML, type: Array
  serialize :check_warnings, coder: YAML, type: Array

  belongs_to :report, class_name: "LinkCheckerApiReport"

  def self.attributes_from_link_report(payload)
    {
      uri: payload.fetch("uri"),
      status: payload.fetch("status"),
      checked: payload.fetch("checked"),
      check_dangers: payload.fetch("dangers", []),
      check_errors: payload.fetch("errors", []),
      check_warnings: payload.fetch("warnings", []),
      problem_summary: payload.fetch("problem_summary"),
      suggested_fix: payload.fetch("suggested_fix"),
    }
  end
end
