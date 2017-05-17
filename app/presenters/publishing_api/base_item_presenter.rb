module PublishingApi
  class BaseItemPresenter
    attr_accessor :item, :title, :need_ids, :locale

    def initialize(item, title: nil, need_ids: nil, locale: I18n.locale.to_s)
      self.item = item
      self.title = title || item.try(:title)
      self.need_ids = need_ids || item.try(:need_ids)
      self.locale = locale
    end

    def base_attributes
      {
        title: title,
        locale: locale,
        need_ids: need_ids,
        publishing_app: "whitehall",
        redirects: [],
      }
    end
  end
end
