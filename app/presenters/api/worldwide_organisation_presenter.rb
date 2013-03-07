class Api::WorldwideOrganisationPresenter < Draper::Base
  class << self
    def paginate(collection)
      page = Api::Paginator.paginate(collection, h.params)
      Api::PagePresenter.new decorate(page)
    end
  end

  def as_json(options = {})
    {
      id: h.api_worldwide_organisation_url(model, host: h.public_host),
      title: model.name,
      format: 'Worldwide Organisation',
      updated_at: model.updated_at,
      web_url: h.worldwide_organisation_url(model, host: h.public_host),
      details: {
        slug: model.slug,
        summary: model.summary,
        description: h.govspeak_to_html(model.description),
        services: services_for_json,
      },
      offices: offices_as_json,
      sponsors: sponsors_as_json,
    }
  end

  def links
    [
      [h.api_worldwide_organisation_url(model, host: h.public_host), {'rel' => 'self'}]
    ]
  end

  def services_for_json
    if model.services.present?
      h.govspeak_to_html(model.services)
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
      web_url: h.organisation_url(sponsor, host: h.public_host),
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

  def office_as_json(office_model)
    {
      title: office_model.contact.title,
      format: 'World Office',
      updated_at: office_model.updated_at,
      details: {
        email: office_model.contact.email || '',
        description: office_model.contact.comments || '',
        contact_form_url: office_model.contact.contact_form_url || '',
        type: office_model.worldwide_office_type.name
      }
    }.merge(office_addresss_as_json(office_model)).
      merge(office_contact_numbers_as_json(office_model)).
      merge(office_services_as_json(office_model))
  end

  def office_addresss_as_json(office_model)
    AddressFormatter::Json.from_contact(office_model.contact).render
  end

  def office_contact_numbers_as_json(office_model)
    {
      contact_numbers: office_model.contact.contact_numbers.map do |contact_number|
        {
          label: contact_number.label,
          number: contact_number.number
        }
      end
    }
  end

  def office_services_as_json(office_model)
    {
      services: office_model.services.map do |service|
        {
          title: service.name,
          type: service.service_type.name
        }
      end
    }
  end
end
