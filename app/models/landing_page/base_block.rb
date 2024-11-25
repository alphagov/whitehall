class LandingPage::BaseBlock
  include ActiveModel::API

  attr_reader :type

  validates :type, presence: true

  def initialize(source)
    @source = source
    @type = @source["type"]
  end

  def present_for_publishing_api
    @source
  end
end
