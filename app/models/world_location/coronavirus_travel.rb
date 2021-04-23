class WorldLocation::CoronavirusTravel
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_reader :world_location
  attribute :rag_status, :string
  attribute :watchlist_rag_status, :string
  attribute :next_rag_status, :string
  attribute :next_rag_applies_at, :datetime

  def initialize(world_location)
    @world_location = world_location

    if world_location.coronavirus_next_rag_applies?
      super({ rag_status: world_location.coronavirus_next_rag_status })
    else
      super({
        rag_status: world_location.coronavirus_rag_status,
        watchlist_rag_status: world_location.coronavirus_watchlist_rag_status,
        next_rag_status: world_location.coronavirus_next_rag_status,
        next_rag_applies_at: world_location.coronavirus_next_rag_applies_at,
      })
    end
  end

  def save
    return false unless valid?

    @world_location.update!(
      coronavirus_rag_status: rag_status,
      coronavirus_watchlist_rag_status: watchlist_rag_status,
      coronavirus_next_rag_status: next_rag_status,
      coronavirus_next_rag_applies_at: next_rag_applies_at,
    )
  end
end
