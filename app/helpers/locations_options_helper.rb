module LocationsOptionsHelper
  def locations_options(selected_locations = [])
    selected_values = selected_locations.any? ? selected_locations.map(&:slug) : %w[all]
    select_options(selected_values)
  end

private

  def select_options(selected)
    world_locations = WorldLocation.includes(:translations).ordered_by_name.map { |l| [l.name, l.slug] }
    all_locations = [[I18n.t("document_filters.world_locations.all"), "all"]].concat(world_locations)

    all_locations.map do |location|
      {
        "text": location[0],
        "value": location[1],
        "selected": (true if selected.any?(location[1])),
      }
    end
  end
end
