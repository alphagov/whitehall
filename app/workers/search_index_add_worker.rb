class SearchIndexAddWorker < WorkerBase
  attr_reader :id, :class_name

  def perform(class_name, id)
    @class_name = class_name
    @id = id

    searchable_instance = find_searchable_instance
    return unless searchable_instance

    if searchable_instance.can_index_in_search?
      add_to_search_index(searchable_instance)
    else
      logger.warn("SearchIndexAddWorker: Was asked to index #{class_name} with id #{id}, but it was unindexable (#{Time.zone.now.utc}).")
    end
  rescue StandardError => e
    logger.error("SearchIndexAddWorker: Error adding #{class_name} with id #{id} to search index: #{e.message}")
  end

private

  def find_searchable_instance
    searchable_class.find_by(id:)
  rescue StandardError => e
    logger.error("SearchIndexAddWorker: Error finding #{class_name} with id #{id}: #{e.message}")
    nil
  end

  def add_to_search_index(searchable_instance)
    index = Whitehall::SearchIndex.for(searchable_instance.search_api_index, logger:)
    index.add searchable_instance.search_index
  rescue StandardError => e
    logger.error("SearchIndexAddWorker: Error adding #{class_name} with id #{id} to search index: #{e.message}")
  end

  def searchable_class
    if searchable_class_names.include?(class_name)
      class_name.constantize
    else
      raise ArgumentError, "#{class_name} is not a searchable class"
    end
  end

  def searchable_class_names
    SearchApiPresenters.searchable_classes.map(&:name)
  end
end
