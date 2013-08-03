class TopicPresenter < Struct.new(:topic)
  def as_json(options = {})
    topic.attributes.slice('id', 'name')
  end
end
