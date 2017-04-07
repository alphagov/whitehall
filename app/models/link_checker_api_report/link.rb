class LinkCheckerApiReport::Link < ActiveRecord::Base
  serialize :check_errors, Hash
  serialize :check_warnings, Hash

  belongs_to :report, class_name: LinkCheckerApiReport

  def self.attributes_from_link_report(payload)
    {
      uri: payload.fetch("uri"),
      status: payload.fetch("status"),
      checked: payload.fetch("checked"),
      check_warnings: payload.fetch("warnings", {}),
      check_errors: payload.fetch("errors", {}),
    }
  end
end
