# A bunch of helpers for efficiently generating select options for taggable
# content, e.g. topics, organisations, etc.
module Admin::TaggableContentHelper

  # Returns an Array that represents the curret set of taggable (new-world)
  # policies. Each element of the array consists of two values: the name and
  # the content id of the policy
  #
  # If the Policy is part of a Policy Area, its name will be displayed as:
  # Policy Area 2: Policy
  def taggable_policy_content_ids_container
    Policy.all.map { |policy|
      [
        policy.internal_name || policy.title,
        policy.content_id,
      ]
    }
  end

  # Returns an Array that represents the current set of taggable topics.
  # Each element of the array consists of two values: the name and ID of the
  # topic.
  def taggable_topics_container
    Rails.cache.fetch(taggable_topics_cache_digest, expires_in: 1.day) do
      Topic.order(:name).map { |t| [t.name, t.id] }
    end
  end

  # Returns an Array that represents the current set of taggable topical
  # events. Each element of the array consists of two values: the name and ID
  # of the topical event.
  def taggable_topical_events_container
    Rails.cache.fetch(taggable_topical_events_cache_digest, expires_in: 1.day) do
      TopicalEvent.order(:name).map { |te| [te.name, te.id] }
    end
  end

  # Returns an Array that represents the current set of taggable organisations.
  # Each element of the array consists of two values: the select_name and the
  # ID of the organisation
  def taggable_organisations_container
    Rails.cache.fetch(taggable_organisations_cache_digest, expires_in: 1.day) do
      Organisation.with_translations.order('organisation_translations.name').map { |o| [o.select_name, o.id] }
    end
  end

  # Returns an Array that represents the current set of taggable ministerial
  # role appointments (both past and present). Each element of the array
  # consists of two values: a selectable label (consisting of the person, the
  # role, the date the role was held if it's in the past, and the organisations
  # the person belongs to) and the ID of the role appointment.
  def taggable_ministerial_role_appointments_container
    Rails.cache.fetch(taggable_ministerial_role_appointments_cache_digest, expires_in: 1.day) do
      role_appointments_container_for(RoleAppointment.for_ministerial_roles)
    end
  end

  # Returns an Array that represents the current set of taggable roles (both
  # past and present). Each element of the array consists of two values: a
  # selectable label (consisting of the person, the role, the date the role was
  # held if it's in the past, and the organisations the person belongs to) and
  # the ID of the role appointment.
  def taggable_role_appointments_container
    Rails.cache.fetch(taggable_role_appointments_cache_digest, expires_in: 1.day) do
      role_appointments_container_for(RoleAppointment)
    end
  end

  # Returns an Array that represents the taggable ministerial roles. Each
  # element of the array consists of two values: the name of the ministerial
  # role with the organisation and current holder and its ID.
  def taggable_ministerial_roles_container
    Rails.cache.fetch(taggable_ministerial_roles_cache_digest, expires_in: 1.day) do
      MinisterialRole.with_translations.with_translations_for(:organisations).alphabetical_by_person.map do |role|
        ["#{role.name}, #{role.organisations.map(&:name).to_sentence} (#{role.current_person_name})", role.id]
      end
    end
  end

  # Returns an Array that represents the current set of taggable detauled
  # guides. Each element of the array consists of two values: the guide title
  # and its ID.
  def taggable_detailed_guides_container
    Rails.cache.fetch(taggable_detailed_guides_cache_digest, expires_in: 1.day) do
      DetailedGuide.alphabetical.latest_edition.active.map {|d| [d.title, d.id] }
    end
  end

  # Returns an Array that represents the current set of taggable statistical
  # data sets. Each elements of the array consists of two values: the data
  # set title and its ID.
  def taggable_statistical_data_sets_container
    Rails.cache.fetch(taggable_statistical_data_sets_cache_digest, expires_in: 1.day) do
      StatisticalDataSet.with_translations.latest_edition.map do |data_set|
        [data_set.title, data_set.document_id]
      end
    end
  end

  # Returns an Array that represents the taggable world locations. Each element
  # of the array consists of two values: the location name and its ID
  def taggable_world_locations_container
    Rails.cache.fetch(taggable_world_locations_cache_digest, expires_in: 1.day) do
      WorldLocation.ordered_by_name.where(active: true).map { |w| [w.name, w.id] }
    end
  end

  # Returns an Array that represents the taggable alternative format providers.
  # Each element of the array consists of two values: the label (organisation
  # and the email address if avaiable) and the ID of the organisation.
  def taggable_alternative_format_providers_container
    Rails.cache.fetch(taggable_alternative_format_providers_cache_digest, expires_in: 1.day) do
      Organisation.alphabetical.map do |o|
        ["#{o.name} (#{o.alternative_format_contact_email.blank? ? "-" : o.alternative_format_contact_email})", o.id]
      end
    end
  end

  # Returns an Array representing the taggable document collections and their
  # groups. Each element of the array consists of two values: the
  # collection/group name and the ID of the group.
  def taggable_document_collection_groups_container
    Rails.cache.fetch(taggable_document_collection_groups_cache_digest, expires_in: 1.day) do
      DocumentCollection.latest_edition.alphabetical.includes(:groups).flat_map  do |collection|
        collection.groups.map { |group| ["#{collection.title} (#{group.heading})", group.id] }
      end
    end
  end

  # Returns an Array that represents the taggable worldwide organisations.
  # Each element of the array consists of two values: the name of the worldwide
  # organisation and its ID.
  def taggable_worldwide_organisations_container
    Rails.cache.fetch(taggable_worldwide_organisations_cache_digest, expires_in: 1.day) do
      WorldwideOrganisation.with_translations(:en).map {|wo| [wo.name, wo.id] }
    end
  end

  # Returns an MD5 digest representing the current set of taggable topics. This
  # will change if any of the Topics should change or if a new topic is added.
  def taggable_topics_cache_digest
    @_taggable_topics_cache_digest ||= calculate_digest(Topic.order(:id), 'topics')
  end

  # Returns an MD5 digest representing the current set of taggable topical
  # events. This will change if any of the Topics should change or if a new
  # topic event is added.
  def taggable_topical_events_cache_digest
    @_taggable_topical_events_cache_digest ||=  calculate_digest(TopicalEvent.order(:id), 'topical-events')
  end

  # Returns an MD5 digest representing the current set of taggable
  # organisations. This will change if any of the Topics should change or if a
  # new organisation is added.
  def taggable_organisations_cache_digest
    @_taggable_organisations_cache_digest ||= calculate_digest(Organisation.order(:id), 'organisations')
  end

  # Returns an MD5 digest representing the current set of taggable ministerial
  # role appointments. This will change if any role appointments are added or
  # changed, and also if an occupied MinisterialRole is updated.
  def taggable_ministerial_role_appointments_cache_digest
    @_taggable_ministerial_role_appointments_cache_digest ||= begin
      calculate_digest(RoleAppointment.
                        joins(:role).
                        where(roles: { type: "MinisterialRole" }).
                        order("role_appointments.id"), 'ministerial-role-appointments')
    end
  end

  # Returns an MD5 digest representing the current set of taggable ministerial
  # role appointments. This will change if any role appointments are added or
  # changed, and also if an occupied Role is updated.
  def taggable_role_appointments_cache_digest
    @_taggable_role_appointments_cache_digest ||= calculate_digest(RoleAppointment.order(:id), 'role-appointments')
  end

  # Returns an MD5 digest representing the current set of taggable ministerial
  # rile appointments. THis will change if any ministerial role is added or
  # updated.
  def taggable_ministerial_roles_cache_digest
    @_taggable_ministerial_roles_cache_digest ||= calculate_digest(MinisterialRole.order(:id), 'ministerial-roles')
  end

  # Returns an MD5 digest representing all the detailed guides. This wil change
  # if any detailed guides are added or updated.
  def taggable_detailed_guides_cache_digest
    @_taggable_detailed_guides_cache_digest ||= calculate_digest(Document.where(document_type: "DetailedGuide").order(:id), 'detailed-guides')
  end

  # Returns an MD5 digest representing the taggable statistical data sets. This
  # will change if any statistical data set is added or updated.
  def taggable_statistical_data_sets_cache_digest
    @_taggable_statistical_data_sets_cache_digest ||= calculate_digest(Document.where(document_type: "StatisticalDataSet").order(:id), 'statistical-data-sets')
  end

  # Returns an MD5 digest representing the taggable policies. This will change
  # if any policies are added or updated.
  def taggable_policies_cache_digest
    @_taggable_policies_cache_digest ||= calculate_digest(Document.where(document_type: "Policy").order(:id), 'policies')
  end

  # Returns an MD5 digest representing the taggable world locations. This will
  # change if any world locations are added or updated.
  def taggable_world_locations_cache_digest
    @_taggable_world_locations_cache_digest ||= calculate_digest(WorldLocation.order(:id), 'world-locations')
  end

  # Returns an MD5 digest representing the taggable alternative format
  # providers. This will change if any alternative format providers are
  # changed.
  def taggable_alternative_format_providers_cache_digest
    @_taggable_alternative_format_providers_cache_digest ||= calculate_digest(Organisation.order(:id), 'alternative-format-providers')
  end

  # Returns an MD5 digest representing the taggable document collection
  # groups. This will change if any document collection or group within
  # the collection is changed or any new ones are added.
  def taggable_document_collection_groups_cache_digest
    @_taggable_document_collection_groups_cache_digest ||= calculate_digest(Document.where(document_type: "DocumentCollection").order(:id), 'document-collection-groups')
  end

  # Returns an MD5 digest representing the taggable worldwide organisations.
  # This will change if any worldwide organisations are added or updated.
  def taggable_worldwide_organisations_cache_digest
    @_taggable_worldwide_organisations_cache_digest ||= calculate_digest(WorldwideOrganisation.order(:id), 'worldwide-organisations')
  end

  # Note: Taken from Rails 4
  def cache_if(condition, name = {}, options = nil, &block)
    if condition
      cache(name, options, &block)
    else
      yield
    end

    nil
  end

private

  def calculate_digest(scope, digest_name)
    update_timestamps = scope.pluck(:updated_at).map(&:to_i).join
    Digest::MD5.hexdigest "taggable-#{digest_name}-#{update_timestamps}"
  end

  def role_appointments_container_for(scope)
    scope.
      includes(:person).
      with_translations_for(:organisations).
      with_translations_for(:role).
      alphabetical_by_person.map { |appointment| [role_appointment_label(appointment), appointment.id] }
  end

  def role_appointment_label(appointment)
    organisations = appointment.organisations.map(&:name).to_sentence
    person        = appointment.person.name
    role          = appointment.role.name.dup
    unless appointment.current?
      role << " (#{l(appointment.started_at.to_date)} to #{l(appointment.ended_at.to_date)})"
    end

    [person, role, organisations].join(', ')
  end
end
