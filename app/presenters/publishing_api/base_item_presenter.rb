module PublishingApi
  class BaseItemPresenter
    include Presenters::PublishingApi::UpdateTypeHelper

    attr_accessor :item, :title, :locale, :update_type

    def initialize(item, title: nil, locale: I18n.locale.to_s, update_type: nil)
      self.item = item
      self.title = title || item.title
      self.locale = locale
      self.update_type = update_type || default_update_type(item)
    end

    def base_attributes
      {
        title:,
        locale:,
        publishing_app: Whitehall::PublishingApp::WHITEHALL,
        redirects: [],
        update_type:,
      }.merge(PayloadBuilder::LastEditedByEditorId.for(item))
    end
  end
end
