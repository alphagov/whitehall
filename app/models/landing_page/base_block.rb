class LandingPage::BaseBlock
  include ActiveModel::API

  attr_reader :type

  validates :type, presence: true

  def initialize(source)
    @source = source
    @type = @source["type"]
  end

  def present_for_publishing_api
    raise "cannot present invalid block to publishing api - errors: #{errors.to_a}" if invalid?

    @source
  end
end
