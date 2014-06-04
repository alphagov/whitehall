class TopicPresenter < Struct.new(:topic)
  def as_json(_options = {})
    topic.attributes.slice('id', 'name')
  end
end
