class WorldLocationCoronavirusTravelWorker < WorkerBase
  def perform(id)
    world_location = WorldLocation.find(id)
    new_rag_status = world_location.coronavirus_next_rag_status

    world_location.lock!

    WorldLocation.transaction do
      world_location.coronavirus_rag_status = new_rag_status
      world_location.coronavirus_next_rag_status = nil
      world_location.coronavirus_next_rag_applies_at = nil

      world_location.save!
    end
  end
end
