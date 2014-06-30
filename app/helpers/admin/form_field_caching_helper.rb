module Admin::FormFieldCachingHelper

  def cached_worldwide_priority_options
    Rails.cache.fetch("edition_options/worldwide_priorities", expires_in: 30.minutes) do
      WorldwidePriority.published.alphabetical.map {|wp| [wp.title, wp.id] }
    end
  end

  def cached_world_location_options
    Rails.cache.fetch("edition_options/world_locations", expires_in: 30.minutes) do
      WorldLocation.ordered_by_name.map { |wl| [wl.name, wl.id] }
    end
  end

  def cached_ministerial_appointment_options
    Rails.cache.fetch("edition_options/ministerial_roles", expires_in: 30.minutes) do
      ministerial_appointment_options
    end
  end

  def cached_organisation_options
    Rails.cache.fetch("edition_options/lead_organisations", expires_in: 30.minutes) do
      organisations_for_edition_organisations_fields.map { |o| [o.select_name, o.id] }
    end
  end

  def cached_related_policy_options
    Rails.cache.fetch("edition_options/related_policies", expires_in: 30.minutes) do
      related_policy_options
    end
  end

  def cached_alternative_format_provider_options
    Rails.cache.fetch("edition_options/alternative_format_providers", expires_in: 30.minutes) do
      organisations_for_edition_organisations_fields.map {|o| ["#{o.name} (#{o.alternative_format_contact_email || "-"})", o.id]}
    end
  end
end
