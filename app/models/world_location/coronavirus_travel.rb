class WorldLocation::CoronavirusTravel
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_reader :world_location

  attribute :rag_status, :string
  attribute :required_tests, :string

  def initialize(world_location)
    @world_location = world_location

    super({
      rag_status: world_location.coronavirus_rag_status,
      required_tests: world_location.coronavirus_required_tests,
    })
  end

  def save
    return false unless valid?

    @world_location.update!(
      coronavirus_rag_status: rag_status,
      coronavirus_required_tests: required_tests,
    )
  end
end
