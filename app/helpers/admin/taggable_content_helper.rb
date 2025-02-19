# A bunch of helpers for efficiently generating select options for taggable
# content, e.g. topics, organisations, etc.
module Admin::TaggableContentHelper
  # Returns an Array that represents the current set of taggable organisations.
  # Each element of the array consists of two values: the select_name and the
  # ID of the organisation
  def taggable_organisations_container
    cached_taggable_organisations.map do |o|
      [o.select_name, o.id]
    end
  end

  # Returns an Array that represents the current set of taggable ministerial
  # role appointments (both past and present). Each element of the array
  # consists of two values: a selectable label (consisting of the person, the
  # role, the date the role was held if it's in the past, and the organisations
  # the person belongs to) and the ID of the role appointment.
  def taggable_ministerial_role_appointments_container
    cached_taggable_ministerial_role_appointments.map do |appointment|
      [role_appointment_label(appointment), appointment.id]
    end
  end

  def taggable_needs_container
    Services.publishing_api.get_linkables(document_type: "need").to_a.map do |need|
      need.values_at("title", "content_id")
    end
  rescue GdsApi::TimedOutException, GdsApi::HTTPServerError
    stale_data = Rails.cache.fetch("need.linkables")
    return stale_data if stale_data

    raise
  end

  # Returns an Array that represents the current set of taggable roles (both
  # past and present). Each element of the array consists of two values: a
  # selectable label (consisting of the person, the role, the date the role was
  # held if it's in the past, and the organisations the person belongs to) and
  # the ID of the role appointment.
  def taggable_role_appointments_container
    cached_taggable_role_appointments.map do |appointment|
      [role_appointment_label(appointment), appointment.id]
    end
  end

  # Returns an Array that represents the current set of taggable detauled
  # guides. Each element of the array consists of two values: the guide title
  # and its ID.
  def taggable_detailed_guides_container
    cached_taggable_detailed_guides.map do |d|
      [d.title, d.id]
    end
  end

  # Returns an Array that represents the current set of taggable statistical
  # data sets. Each elements of the array consists of two values: the data
  # set title and its ID.
  def taggable_statistical_data_sets_container
    cached_taggable_statistical_data_sets.map do |data_set|
      [data_set.title, data_set.document_id]
    end
  end

  # Returns an Array that represents the taggable world locations. Each element
  # of the array consists of two values: the location name and its ID
  def taggable_world_locations_container
    cached_taggable_world_locations.map do |w|
      [w.name, w.id]
    end
  end

  # Returns an Array that represents the taggable roles. Each element of the
  # array consists of two values: the role name and its ID
  def taggable_roles_container
    cached_taggable_roles.map do |w|
      [w.name, w.id]
    end
  end

  # Returns an Array that represents the taggable alternative format providers.
  # Each element of the array consists of two values: the label (organisation
  # and the email address if avaiable) and the ID of the organisation.
  def taggable_alternative_format_providers_container
    cached_taggable_alternative_format_providers.map do |o|
      ["#{o.name} (#{o.alternative_format_contact_email.presence || '-'})", o.id]
    end
  end

  # Returns an Array that represents the taggable worldwide organisations.
  # Each element of the array consists of two values: the name of the worldwide
  # organisation and its ID.
  def taggable_worldwide_organisations_container
    cached_taggable_worldwide_organisations.map do |wo|
      [wo.title, wo.document.id]
    end
  end

  def cached_taggable_organisations
    Rails.cache.fetch(taggable_organisations_cache_digest, expires_in: 1.day) do
      Organisation.with_translations.order("organisation_translations.name")
    end
  end

  # Returns an MD5 digest representing the current set of taggable topical
  # events. This will change if any of the Topics should change or if a new
  # topic event is added.
  def taggable_topical_events_cache_digest
    @taggable_topical_events_cache_digest ||= calculate_digest(TopicalEvent.order(:id), "topical-events")
  end

  # Returns an MD5 digest representing the current set of taggable
  # organisations. This will change if any of the Topics should change or if a
  # new organisation is added.
  def taggable_organisations_cache_digest
    @taggable_organisations_cache_digest ||= calculate_digest(Organisation.order(:id), "organisations")
  end

  def cached_taggable_ministerial_role_appointments
    Rails.cache.fetch(taggable_ministerial_role_appointments_cache_digest, expires_in: 1.day) do
      role_appointments_container_for(RoleAppointment.for_ministerial_roles)
    end
  end

  # Returns an MD5 digest representing the current set of taggable ministerial
  # role appointments. This will change if any role appointments are added or
  # changed, and also if an occupied MinisterialRole is updated.
  def taggable_ministerial_role_appointments_cache_digest
    @taggable_ministerial_role_appointments_cache_digest ||= calculate_digest(
      RoleAppointment
                              .joins(:role)
                              .where(roles: { type: "MinisterialRole" })
                              .order("role_appointments.started_at"),
      "ministerial-role-appointments",
    )
  end

  def cached_taggable_role_appointments
    Rails.cache.fetch(taggable_role_appointments_cache_digest, expires_in: 1.day) do
      role_appointments_container_for(RoleAppointment)
    end
  end

  # Returns an MD5 digest representing the current set of taggable ministerial
  # role appointments. This will change if any role appointments are added or
  # changed, and also if an occupied Role is updated.
  def taggable_role_appointments_cache_digest
    @taggable_role_appointments_cache_digest ||= calculate_digest(RoleAppointment.order(:id), "role-appointments")
  end

  def cached_taggable_detailed_guides
    Rails.cache.fetch(taggable_detailed_guides_cache_digest, expires_in: 1.day) do
      DetailedGuide.alphabetical.latest_edition.active
    end
  end

  # Returns an MD5 digest representing all the detailed guides. This wil change
  # if any detailed guides are added or updated.
  def taggable_detailed_guides_cache_digest
    @taggable_detailed_guides_cache_digest ||= calculate_digest(Document.where(document_type: "DetailedGuide").order(:id), "detailed-guides")
  end

  def cached_taggable_statistical_data_sets
    Rails.cache.fetch(taggable_statistical_data_sets_cache_digest, expires_in: 1.day) do
      StatisticalDataSet.with_translations.latest_edition
    end
  end

  # Returns an MD5 digest representing the taggable statistical data sets. This
  # will change if any statistical data set is added or updated.
  def taggable_statistical_data_sets_cache_digest
    @taggable_statistical_data_sets_cache_digest ||= calculate_digest(Document.where(document_type: "StatisticalDataSet").order(:id), "statistical-data-sets")
  end

  def cached_taggable_world_locations
    Rails.cache.fetch(taggable_world_locations_cache_digest, expires_in: 1.day) do
      WorldLocation.ordered_by_name.where(active: true)
    end
  end

  # Returns an MD5 digest representing the taggable world locations. This will
  # change if any world locations are added or updated.
  def taggable_world_locations_cache_digest
    @taggable_world_locations_cache_digest ||= calculate_digest(WorldLocation.order(:id), "world-locations")
  end

  def cached_taggable_roles
    Rails.cache.fetch(taggable_roles_cache_digest, expires_in: 1.day) do
      Role.order(:name)
    end
  end

  # Returns an MD5 digest representing the taggable roles. This will
  # change if any world locations are added or updated.
  def taggable_roles_cache_digest
    @taggable_roles_cache_digest ||= calculate_digest(Role.order(:id), "roles")
  end

  def cached_taggable_alternative_format_providers
    Rails.cache.fetch(taggable_alternative_format_providers_cache_digest, expires_in: 1.day) do
      Organisation.alphabetical
    end
  end

  # Returns an MD5 digest representing the taggable alternative format
  # providers. This will change if any alternative format providers are
  # changed.
  def taggable_alternative_format_providers_cache_digest
    @taggable_alternative_format_providers_cache_digest ||= calculate_digest(Organisation.order(:id), "alternative-format-providers")
  end

  def cached_taggable_worldwide_organisations
    Rails.cache.fetch(taggable_worldwide_organisations_cache_digest, expires_in: 1.day) do
      WorldwideOrganisation.with_translations.latest_edition
    end
  end

  # Returns an MD5 digest representing the taggable worldwide organisations. This
  # will change if any worldwide organisation is added or updated.
  def taggable_worldwide_organisations_cache_digest
    @taggable_worldwide_organisations_cache_digest ||= calculate_digest(Document.where(document_type: "WorldwideOrganisation").order(:id), "worldwide-organisations")
  end

private

  def calculate_digest(scope, digest_name)
    update_timestamps = scope.pluck(:updated_at).map(&:to_i).join
    Digest::MD5.hexdigest "taggable-#{digest_name}-#{update_timestamps}"
  end

  def role_appointments_container_for(scope)
    scope
      .includes(:person)
      .with_translations_for(:organisations)
      .with_translations_for(:role)
      .ascending_start_date
  end

  def role_appointment_label(appointment)
    organisations = appointment.organisations.map(&:name).to_sentence
    person        = appointment.person.name
    role          = appointment.role.name.dup
    unless appointment.current?
      role << " (#{l(appointment.started_at.to_date)} to #{l(appointment.ended_at.to_date)})"
    end

    [person, role, organisations].join(", ")
  end
end
