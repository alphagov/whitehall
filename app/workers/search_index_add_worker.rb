class SearchIndexAddWorker
  include Sidekiq::Worker

  attr_reader :id, :class_name

  def perform(class_name, id)
    @class_name = class_name
    @id = id

    if searchable_instance.can_index_in_search?
      index = Whitehall::SearchIndex.for(searchable_instance.rummager_index)
      index.add searchable_instance.search_index
    end
  end

private

  def searchable_instance
    @searchable_instance ||= searchable_class.find(id)
  end

  def searchable_class
    if searchable_class_names.include?(class_name)
      class_name.constantize
    else
      raise ArgumentError, "#{class_name} is not a searchable class"
    end
  end

  def searchable_class_names
    Whitehall.searchable_classes.map(&:name)
  end
end
