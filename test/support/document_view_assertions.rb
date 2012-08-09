module DocumentViewAssertions
  def self.included(base)
    base.send(:include, PublicDocumentRoutesHelper)
    base.send(:include, ActionDispatch::Routing::UrlFor)
    base.send(:include, Rails.application.routes.url_helpers)
    base.default_url_options[:host] = 'test.host'
  end
end
