class LinkCheckerApiReport::Link < ActiveRecord::Base
  serialize :check_errors, Array
  serialize :check_warnings, Array

  belongs_to :report, class_name: LinkCheckerApiReport

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
