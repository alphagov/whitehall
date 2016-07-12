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
      }.tap do |_|
        if item.respond_to?(:analytics_identifier)
          # FIXME: remove this altogether once the three presenters below are refactored.
          raise ArgumentError, "analytics_identifier needed in content hash for Organisation, WorldLocations, or WorldwideOrganisations"
        end
      end
    end
  end
end
