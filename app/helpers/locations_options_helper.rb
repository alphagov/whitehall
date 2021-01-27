module LocationsOptionsHelper
  def locations_options(selected_locations = [])
    selected_values = selected_locations.any? ? selected_locations.map(&:slug) : %w[all]
    world_locations_filter_option_html(selected_values)
  end

private

  def world_locations_filter_option_html(selected_value)
    world_locations = WorldLocation.includes(:translations).ordered_by_name.map { |l| [l.name, l.slug] }

    selected_values = Array(selected_value)
    options_for_select([[I18n.t("document_filters.world_locations.all"), "all"]], selected_values) +
      options_for_select(world_locations, selected_values)
  end
end
