class DetailedGuidePresenter < Whitehall::Decorators::Decorator
  include EditionPresenterHelper

  delegate_instance_methods_of DetailedGuide

  def related_mainstream_content_title
    @related_mainstream_content_title ||= begin
      item = Whitehall.content_store.content_item(related_mainstream_base_path)
      item["title"]
    rescue GdsApi::TimedOutException
      ""
    end
  end

  def additional_related_mainstream_content_title
    @additional_related_mainstream_content_title ||= begin
      item = Whitehall.content_store.content_item(additional_related_mainstream_base_path)
      item["title"]
    rescue GdsApi::TimedOutException
      ""
    end
  end
end
