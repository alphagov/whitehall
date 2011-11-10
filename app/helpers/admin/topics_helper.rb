module Admin::TopicsHelper
  def topic_css_classes(topic)
    result = ''
    result << ' featured' if topic.featured?
  end
end