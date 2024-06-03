module Admin
  module ObjectStore
    module ItemsHelper
      def edition_name(edition)
        edition.item_type.titleize
      end

      def render_partial_path(edition, partial_name)
        render partial: partial_path(edition, partial_name), object: edition, as: edition.item_type
      end

      def partial_path(edition, partial_name)
        dirname = edition.item_type.pluralize
        File.join("admin", "object_store", dirname, partial_name)
      end

      def object_store_item_form(edition)
        form_for edition, url: form_url_for_object_store_item(edition), as: edition.item_type do |form|
          yield(form)
          concat render("govuk_publishing_components/components/button", {
            text: "Save",
            value: "save",
            name: "save",
            data_attributes: {
              module: "gem-track-click",
              "track-category": "form-button",
              "track-action": "object-store-item-button",
              "track-label": "Save",
            },
          })
        end
      end

      def form_url_for_object_store_item(edition)
        admin_object_store_items_path(item_type: edition.item_type)
      end
    end
  end
end
