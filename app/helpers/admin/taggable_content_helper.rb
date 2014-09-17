# A bunch of helpers for efficiently generating select options for taggable
# content, e.g. topics, organisations, etc.
module Admin::TaggableContentHelper

  # Returns an Array that represents the current set of taggable topics.
  # Each element of the array consists of two values: the name and ID of the
  # topic.
  def taggable_topics_container
    Rails.cache.fetch(taggable_topics_cache_digest) do
      Topic.order(:name).map { |t| [t.name, t.id] }
    end
  end

  # Returns an Array that represents the current set of taggable topical
  # events. Each element of the array consists of two values: the name and ID
  # of the topical event.
  def taggable_topical_events_container
    Rails.cache.fetch(taggable_topical_events_cache_digest) do
      TopicalEvent.order(:name).map { |te| [te.name, te.id] }
    end
  end

  # Returns an Array that represents the current set of taggable organisations.
  # Each element of the array consists of two values: the select_name and the
  # ID of the organisation
  def taggable_organisations_container
    Rails.cache.fetch(taggable_organisations_cache_digest) do
      Organisation.with_translations.order(:name).map { |o| [o.select_name, o.id] }
    end
  end

  # Returns an Array that represents the current set of taggable ministerial
  # roles (both past and present). Each element of the array consists fo two
  # values: a selectable label (consisting of the person, the role, the date
  # the role was held if it's in the past, and the organisations the person
  # belongs to) and the ID of the role appointment.
  def taggable_ministerial_role_appointments_container
    Rails.cache.fetch(taggable_ministerial_role_appointments_cache_digest) do
      role_appointments_container_for(RoleAppointment.for_ministerial_roles)
    end
  end

  # Returns an Array that represents the current set of taggable roles (both
  # past and present). Each element of the array consists fo two values: a
  # selectable label (consisting of the person, the role, the date the role was
  # held if it's in the past, and the organisations the person belongs to) and
  # the ID of the role appointment.
  def taggable_role_appointments_container
    Rails.cache.fetch(taggable_role_appointments_cache_digest) do
      role_appointments_container_for(RoleAppointment)
    end
  end

  # Returns an Array that represents the current set of taggable detauled
  # guides. Each element of the array consists of two values: the guide title
  # and its ID.
  def taggable_detailed_guides_container
    Rails.cache.fetch(taggable_detailed_guides_cache_digest) do
      DetailedGuide.alphabetical.latest_edition.active.map {|d| [d.title, d.id] }
    end
  end

  # Returns an Array that represents the current set of taggable statistical
  # data sets. Each elements of the array consists of two values: the data
  # set title and its ID.
  def taggable_statistical_data_sets_container
    Rails.cache.fetch(taggable_statistical_data_sets_cache_digest) do
      StatisticalDataSet.with_translations.latest_edition.map do |data_set|
        [data_set.title, data_set.document_id]
      end
    end
  end

  # Returns an Array that represents the taggable published worldwide
  # priorities. Each element of the array consists of two values: the
  # worldwide priority title and its ID.
  def taggable_worldwide_priorities_container
    Rails.cache.fetch(taggable_worldwide_priorities_cache_digest) do
      WorldwidePriority.alphabetical.published.map {|w| [w.title, w.id] }
    end
  end

  # Returns an MD5 digest representing the current set of taggable topics. This
  # will change if any of the Topics should change or if a new topic is added.
  def taggable_topics_cache_digest
    update_timestamps = Topic.order(:id).pluck(:updated_at).map(&:to_i).join
    Digest::MD5.hexdigest "taggable-topics-#{update_timestamps}"
  end

  # Returns an MD5 digest representing the current set of taggable topical
  # events. This will change if any of the Topics should change or if a new
  # topic event is added.
  def taggable_topical_events_cache_digest
    update_timestamps = TopicalEvent.order(:id).pluck(:updated_at).map(&:to_i).join
    Digest::MD5.hexdigest "taggable-topical-events-#{update_timestamps}"
  end

  # Returns an MD5 digest representing the current set of taggable
  # organisations. This will change if any of the Topics should change or if a
  # new organisation is added.
  def taggable_organisations_cache_digest
    @taggable_organisations_cache_digest ||= begin
      update_timestamps = Organisation.order(:id).pluck(:updated_at).map(&:to_i).join
      Digest::MD5.hexdigest "taggable-organisations-#{update_timestamps}"
    end
  end

  # Returns an MD5 digest representing the current set of taggable ministerial
  # role appointments. This will change if any role appointments are added or
  # changed, and also if an occupied MinisterialRole is updated.
  def taggable_ministerial_role_appointments_cache_digest
    update_timestamps = RoleAppointment.
                          joins(:role).
                          where(roles: { type: MinisterialRole}).
                          order("role_appointments.id").
                          pluck(:updated_at).
                          map(&:to_i).join
    Digest::MD5.hexdigest "taggable-ministerial-role-appointments-#{update_timestamps}"
  end

  # Returns an MD5 digest representing the current set of taggable ministerial
  # role appointments. This will change if any role appointments are added or
  # changed, and also if an occupied MinisterialRole is updated.
  def taggable_role_appointments_cache_digest
    update_timestamps = RoleAppointment.order(:id).pluck(:updated_at).map(&:to_i).join
    Digest::MD5.hexdigest "taggable-role-appointments-#{update_timestamps}"
  end

  # Returns an MD5 digest representing all the detailed guides. This wil change
  # if any detailed guides are added or updated.
  def taggable_detailed_guides_cache_digest
    update_timestamps = Document.where(document_type: DetailedGuide).order(:id).pluck(:updated_at).map(&:to_i).join
    Digest::MD5.hexdigest "taggable-detailed-guides-#{update_timestamps}"
  end

  # Returns an MD5 digest representing the taggable statistical data sets. This
  # will change if any statistical data set is added or updated.
  def taggable_statistical_data_sets_cache_digest
    update_timestamps = Document.where(document_type: StatisticalDataSet).order(:id).pluck(:updated_at).map(&:to_i).join
    Digest::MD5.hexdigest "taggable-statistical-data-sets-#{update_timestamps}"
  end

  # Returns an MD5 digest representing the taggable worldwide priorities. This
  # will change if any worldwide priorities are added or updated.
  def taggable_worldwide_priorities_cache_digest
    update_timestamps = Document.where(document_type: WorldwidePriority).order(:id).pluck(:updated_at).map(&:to_i).join
    Digest::MD5.hexdigest "taggable-worldwide-priorities-#{update_timestamps}"
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
    role          = appointment.role.name
    unless appointment.current?
      role << " (#{l(appointment.started_at.to_date)} to #{l(appointment.ended_at.to_date)})"
    end

    [person, role, organisations].join(', ')
  end
end
