# frozen_string_literal: true

class Admin::WorldwideOrganisations::Show::SummaryListComponent < ViewComponent::Base
  def initialize(worldwide_organisation:)
    @worldwide_organisation = worldwide_organisation
  end

private

  attr_reader :worldwide_organisation

  def items
    [
      name_item,
      world_location_items,
      sponsoring_organisation_items,
      logo_formatted_name_item,
      default_news_image_item,
    ]
    .flatten
    .compact
  end

  def name_item
    {
      field: "Name",
      value: worldwide_organisation.name,
    }
  end

  def world_location_items
    return if world_locations.blank?

    if world_locations.many?
      world_locations.each_with_index.map do |world_location, index|
        {
          field: "World location #{index + 1}",
          value: world_location.name,
          edit: view_link(world_location),
        }
      end
    else
      {
        field: "World location",
        value: world_locations.first.name,
        edit: view_link(world_locations.first),
      }
    end
  end

  def sponsoring_organisation_items
    return if sponsoring_organisations.blank?

    if sponsoring_organisations.many?
      sponsoring_organisations.each_with_index.map do |sponsoring_organisation, index|
        {
          field: "Sponsoring organisation #{index + 1}",
          value: sponsoring_organisation.name,
          edit: view_link(sponsoring_organisation),
        }
      end
    else
      {
        field: "Sponsoring organisation",
        value: sponsoring_organisations.first.name,
        edit: view_link(sponsoring_organisations.first),
      }
    end
  end

  def view_link(model)
    {
      href: model.public_url,
      link_text: "View",
    }
  end

  def logo_formatted_name_item
    return if worldwide_organisation.logo_formatted_name.blank?

    {
      field: "Logo formatted name",
      value: worldwide_organisation.logo_formatted_name,
    }
  end

  def default_news_image_item
    return if worldwide_organisation.default_news_image.blank?

    {
      field: "Default news image",
      value: image_tag(worldwide_organisation.default_news_image.file.url(:s300)),
    }
  end

  def world_locations
    @world_locations ||= worldwide_organisation.world_locations
  end

  def sponsoring_organisations
    @sponsoring_organisations ||= worldwide_organisation.sponsoring_organisations
  end
end
