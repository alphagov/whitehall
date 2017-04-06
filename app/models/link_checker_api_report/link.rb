class LinkCheckerApiReport::Link < ActiveRecord::Base
  serialize :check_errors, Hash
  serialize :check_warnings, Hash

  belongs_to :report, class_name: LinkCheckerApiReport
end
