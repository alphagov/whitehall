module Admin::ObjectStore
  class ItemsController < Admin::EditionsController
  private

    def edition_class
      ObjectStore::Item
    end

    def permitted_edition_attributes
      (super << ObjectStore.item_type_by_name(params[:item_type]).field_names).flatten
    end

    def show_or_edit_path
      if params[:save].present?
        edit_admin_object_store_item_path(@edition.item_type, @edition)
      else
        admin_object_store_item_path @edition
      end
    end

    def new_edition
      edition = edition_class.new(item_type: params[:item_type])
      edition.assign_attributes(new_edition_params)
      edition
    end
  end
end
