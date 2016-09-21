class DetailedGuidePresenter < Whitehall::Decorators::Decorator
  include EditionPresenterHelper

  delegate_instance_methods_of DetailedGuide

  def related_mainstream_content_title
    @related_mainstream_content_title ||= begin
      content_id = self.model.related_mainstream_content_ids.first
      item = Whitehall.publishing_api_v2_client.get_content!(content_id)
      item.title
    rescue GdsApi::TimedOutException
      ""
    end
  end

  def additional_related_mainstream_content_title
    @additional_related_mainstream_content_title ||= begin
      content_id = self.model.related_mainstream_content_ids[1] if self.model.related_mainstream_content_ids[1]
      item = Whitehall.publishing_api_v2_client.get_content!(content_id)
      item.title
    rescue GdsApi::TimedOutException
      ""
    end
  end
end
