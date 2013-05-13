module Whitehall
  class UrlMaker
    include Rails.application.routes.url_helpers
    include PublicDocumentRoutesHelper
    include MainstreamCategoryRoutesHelper
    include FilterRoutesHelper
    include LocalisedUrlPathHelper

    def initialize(default_options = {})
      unless default_options.empty?
        self.singleton_class.default_url_options = UrlMaker.default_url_options.merge(default_options)
      end
    end
  end
end  