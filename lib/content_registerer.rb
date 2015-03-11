class ContentRegisterer
  def initialize(scope, logger=NullLogger.instance)
    @scope = scope
    @logger = logger
  end

  def register!
    logger.info "Updating all #{model_name} entries in the content register"

    scope.find_each do |instance|
      register_entry(instance)
      logger << '.'
    end

    logger.info "\n#{count} #{plural_name} registered with content register"
  end

private
  attr_accessor :logger, :scope

  def register_entry(instance)
    Whitehall.content_register.put_entry(instance.content_id, entry_for(instance))
  end

  def entry_for(instance)
    {
      base_path: instance.search_index['link'],
      format: format,
      title: instance.search_index['title'],
    }
  end

  def count
    scope.count
  end

  def format
    model_name.underscore
  end

  def model_name
    scope.first.class.name
  end

  def plural_name
    model_name.pluralize
  end
end
