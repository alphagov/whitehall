class Admin::ModelHistoryListComponent < ViewComponent::Base
  attr_reader :versions

  def initialize(versions:)
    @versions = versions
  end
end
