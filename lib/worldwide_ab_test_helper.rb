class WorldwideAbTestHelper
  attr_reader :content

  def initialize(content_file_path = nil)
    @content = YAML.load_file(content_file_path || file_path)
  end

  def has_content_for?(location_slug)
    !!content_for(location_slug)
  end

  def content_for(location_slug)
    content[location_slug]
  end

  def location_for(worldwide_organisation)
    hard_coded_location_for(worldwide_organisation) ||
      worldwide_organisation.world_locations.first
  end

  def is_under_test?(testable_object)
    location = testable_object
    if testable_object.respond_to?(:world_locations)
      location = location_for(testable_object)
    end
    has_content_for?(location.slug)
  end

private

  def root
    Rails.root
  end

  def file_path
    File.join(root, "config/worldwide_publishing_taxonomy_ab_test_content.yml")
  end

  def hard_coded_location_slugs
    {
      "british-high-commission-pretoria" => "south-africa",
      "british-consulate-general-los-angeles" => "usa",
      "did-south-africa" => "south-africa",
      "british-deputy-high-commission-kolkata" => "india",
      "uk-science-and-innovation-network" => "australia",
    }
  end

  def hard_coded_location_for(worldwide_organisation)
    wwo_slug = worldwide_organisation.slug
    hard_coded_value = hard_coded_location_slugs[wwo_slug]
    return unless hard_coded_value.present?

    locations = worldwide_organisation.world_locations
    locations.find do |location|
      location.slug == hard_coded_value
    end
  end
end
