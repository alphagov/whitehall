class Api::WorldwideOrganisationPresenter < Api::BasePresenter
  def as_json(options = {})
    {
      id: context.api_worldwide_organisation_url(model),
      title: model.name,
      format: 'Worldwide Organisation',
      updated_at: model.updated_at,
      web_url: context.worldwide_organisation_url(model, host: context.public_host),
      details: {
        slug: model.slug,
        summary: model.summary,
        description: context.govspeak_to_html(model.description),
        services: services_for_json,
      },
      offices: offices_as_json,
      sponsors: sponsors_as_json,
    }
  end

  def links
    [
      [context.api_worldwide_organisation_url(model), {'rel' => 'self'}]
    ]
  end

  def services_for_json
    if model.services.present?
      context.govspeak_to_html(model.services)
    else
      ''
    end
  end

  def sponsors_as_json
    model.sponsoring_organisations.map { |sponsor| sponsor_as_json(sponsor) }
  end

  def sponsor_as_json(sponsor)
    {
      title: sponsor.name,
      web_url: context.organisation_url(sponsor, host: context.public_host),
      details: {
        acronym: sponsor.acronym || ''
      }
    }
  end

  def offices_as_json
    offices = {}
    offices[:main] = office_as_json(model.main_office) if model.main_office
    offices[:other] = model.other_offices.map { |office| office_as_json(office) }
    offices
  end

  def office_as_json(office_worldwide_organisation)
    {
      title: office_worldwide_organisation.contact.title,
      format: 'World Office',
      updated_at: office_worldwide_organisation.updated_at,
      details: {
        email: office_worldwide_organisation.contact.email || '',
        description: office_worldwide_organisation.contact.comments || '',
        contact_form_url: office_worldwide_organisation.contact.contact_form_url || '',
        access_and_opening_times: office_access_and_opening_times_as_json(office_worldwide_organisation),
        type: office_worldwide_organisation.worldwide_office_type.name
      }
    }.merge(office_addresss_as_json(office_worldwide_organisation)).
      merge(office_contact_numbers_as_json(office_worldwide_organisation)).
      merge(office_services_as_json(office_worldwide_organisation))
  end

  def office_access_and_opening_times_as_json(office_worldwide_organisation)
    if office_worldwide_organisation.access_and_opening_times_body.present?
      context.govspeak_to_html(office_worldwide_organisation.access_and_opening_times_body)
    else
      ''
    end
  end

  def office_addresss_as_json(office_worldwide_organisation)
    AddressFormatter::Json.from_contact(office_worldwide_organisation.contact).render
  end

  def office_contact_numbers_as_json(office_worldwide_organisation)
    {
      contact_numbers: office_worldwide_organisation.contact.contact_numbers.map do |contact_number|
        {
          label: contact_number.label,
          number: contact_number.number
        }
      end
    }
  end

  def office_services_as_json(office_worldwide_organisation)
    {
      services: office_worldwide_organisation.services.map do |service|
        {
          title: service.name,
          type: service.service_type.name
        }
      end
    }
  end
end
