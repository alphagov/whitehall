module PublishingApi
  class BaseItemPresenter
    include UpdateTypeHelper

    attr_accessor :item, :title, :need_ids, :locale, :update_type

    def initialize(item, title: nil, need_ids: nil, locale: I18n.locale.to_s, update_type: nil)
      self.item = item
      self.title = title || item.title
      self.need_ids = need_ids || item.need_ids
      self.locale = locale
      self.update_type = update_type || default_update_type(item)
    end

    def base_attributes
      {
        title: title,
        locale: locale,
        need_ids: need_ids,
        publishing_app: "whitehall",
        redirects: [],
        update_type: update_type,
      }
    end
  end
end
