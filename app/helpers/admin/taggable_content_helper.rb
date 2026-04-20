# A bunch of helpers for efficiently generating select options for taggable
# content, e.g. topics, organisations, etc.
module Admin::TaggableContentHelper
  include ActionView::Helpers::TranslationHelper

  # Legacy: to be removed when topical events have been migrated
  def taggable_topical_events_container(selected_ids = [])
    TopicalEvent.order(:name).map do |topical_event|
      {
        text: topical_event.name,
        value: topical_event.id,
        selected: selected_ids.include?(topical_event.id),
      }
    end
  end

  def taggable_topical_event_documents_container(selected_ids = [])
    Document
      .joins(latest_edition: :translations)
      .where(editions: { configurable_document_type: "topical_event" })
      .preload(latest_edition: :translations)
      .order("edition_translations.title")
      .uniq
      .map do |topical_event_document|
        {
          text: topical_event_document.latest_edition.title,
          value: topical_event_document.id,
          selected: selected_ids.include?(topical_event_document.id),
        }
      end
  end

  def taggable_organisations_container(selected_ids = [])
    Organisation.with_translations.order("organisation_translations.name").map do |o|
      {
        text: o.select_name,
        value: o.id,
        selected: selected_ids.include?(o.id),
      }
    end
  end

  def taggable_ministerial_role_appointments_container(selected_ids = [])
    role_appointments_container_for(RoleAppointment.for_ministerial_roles).map do |appointment|
      {
        text: role_appointment_option_label(appointment),
        value: appointment.id,
        selected: selected_ids.include?(appointment.id),
      }
    end
  end

  def taggable_role_appointments_container(selected_ids = [])
    role_appointments_container_for(RoleAppointment).map do |appointment|
      {
        text: role_appointment_option_label(appointment),
        value: appointment.id,
        selected: selected_ids.include?(appointment.id),
      }
    end
  end

  def taggable_detailed_guides_container(selected_ids = [])
    DetailedGuide.alphabetical.latest_edition.active.map do |d|
      {
        text: d.title,
        value: d.id,
        selected: selected_ids.include?(d.id),
      }
    end
  end

  def taggable_statistical_data_sets_container(selected_ids = [])
    StatisticalDataSet.with_translations.latest_edition.map do |data_set|
      {
        text: data_set.title,
        value: data_set.document_id,
        selected: selected_ids.include?(data_set.document_id),
      }
    end
  end

  def taggable_world_locations_container(selected_ids = [])
    WorldLocation.ordered_by_name.where(active: true).map do |w|
      {
        text: w.name,
        value: w.id,
        selected: selected_ids.include?(w.id),
      }
    end
  end

  def taggable_roles_container(selected_ids = [])
    Role.order(:name).map do |w|
      {
        text: w.name,
        value: w.id,
        selected: selected_ids.include?(w.id),
      }
    end
  end

  def taggable_alternative_format_providers_container(selected_ids = [])
    Organisation.alphabetical.map do |o|
      {
        text: "#{o.name} (#{o.alternative_format_contact_email.presence || '-'})",
        value: o.id,
        selected: selected_ids.include?(o.id),
      }
    end
  end

  def taggable_worldwide_organisations_container(selected_ids = [])
    WorldwideOrganisation.with_translations.latest_edition.map do |wo|
      {
        text: wo.title,
        value: wo.document.id,
        selected: selected_ids.include?(wo.document.id),
      }
    end
  end

private

  def role_appointments_container_for(scope)
    scope
      .includes(:person)
      .with_translations_for(:organisations)
      .with_translations_for(:role)
      .ascending_start_date
  end

  def role_appointment_option_label(appointment)
    organisations = appointment.organisations.map(&:name).to_sentence
    person        = appointment.person.name
    role          = appointment.role.name.dup
    unless appointment.current?
      role << " (#{l(appointment.started_at.to_date)} to #{l(appointment.ended_at.to_date)})"
    end

    [person, role, organisations].join(", ")
  end
end
