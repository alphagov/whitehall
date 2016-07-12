module PublishingApiPresenters
  class BaseItem
    extend Forwardable

    attr_accessor :item, :locale
    def_delegators :item, :title, :need_ids

    def initialize(item, locale: I18n.locale.to_s)
      self.item = item
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
