module PublishingApi
  class BaseItemPresenter
    include UpdateTypeHelper

    attr_accessor :item, :title, :locale, :update_type

    def initialize(item, title: nil, locale: I18n.locale.to_s, update_type: nil)
      self.item = item
      self.title = title || item.title
      self.locale = locale
      self.update_type = update_type || default_update_type(item)
    end

    def base_attributes
      {
        title: title,
        locale: locale,
        publishing_app: "whitehall",
        redirects: [],
        update_type: update_type,
      }
    end
  end
end
