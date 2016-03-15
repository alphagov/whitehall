require_relative "../publishing_api_presenters"

class PublishingApiPresenters::Item
  extend Forwardable

  def_delegators :item, :base_path, :content_id, :title, :description, :need_ids, :public_updated_at
  attr_accessor :update_type

  def initialize(item, update_type: nil)
    self.item = item
    self.update_type = update_type || default_update_type
  end

  def content
    {
      base_path: base_path,
      title: title,
      description: description,
      format: document_format,
      locale: I18n.locale.to_s,
      need_ids: need_ids,
      public_updated_at: public_updated_at,
      publishing_app: "whitehall",
      rendering_app: rendering_app,
      routes: routes,
      redirects: [],
      details: details,
    }.tap do |content_hash|
      if item.respond_to?(:analytics_identifier)
        content_hash.merge!(analytics_identifier: item.analytics_identifier)
      end
    end
  end

  def links
    PublishingApiPresenters::LinkExtractor.new(item).extract(filter_links)
  end

private

  attr_accessor :item

  def rendering_app
    Whitehall::RenderingApp::WHITEHALL_FRONTEND
  end

  def routes
    [{ path: base_path, type: "exact" }]
  end

  def base_path
    Whitehall.url_maker.polymorphic_path(item)
  end

  def default_update_type
    "major"
  end

  def need_ids
    []
  end

  def details
    {}
  end
end
