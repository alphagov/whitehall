module Admin::OperationalFieldHelper
  def operational_field_select_options(edition)
    options_from_collection_for_select(OperationalField.all, "id", "name", edition.operational_field_id)
  end
end
