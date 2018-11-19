class SearchIndexAddWorker < WorkerBase
  attr_reader :id, :class_name

  def perform(class_name, id, extra_metadata = nil)
    @class_name = class_name
    @id = id

    if searchable_instance.nil?
      logger.warn("SearchIndexAddWorker: Could not find #{class_name} with id #{id} (#{Time.zone.now.utc}).")
    elsif !searchable_instance.can_index_in_search?
      logger.warn("SearchIndexAddWorker: Was asked to index #{class_name} with id #{id}, but it was unindexable (#{Time.zone.now.utc}).")
    else
      index = Whitehall::SearchIndex.for(searchable_instance.rummager_index, logger: logger)

      payload = searchable_instance.search_index
      payload = payload.merge(extra_metadata) if extra_metadata.is_a? Hash

      index.add(payload)
    end
  end

private

  def searchable_instance
    @searchable_instance ||= searchable_class.find_by(id: id)
  end

  def searchable_class
    if searchable_class_names.include?(class_name)
      class_name.constantize
    else
      raise ArgumentError, "#{class_name} is not a searchable class"
    end
  end

  def searchable_class_names
    RummagerPresenters.searchable_classes.map(&:name)
  end
end
