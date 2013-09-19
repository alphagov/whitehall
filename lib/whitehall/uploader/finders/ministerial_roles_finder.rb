class Whitehall::Uploader::Finders::MinisterialRolesFinder
  def self.find(date, *slugs, logger, line_number)
    slugs = slugs.reject { |slug| slug.blank? }

    people = slugs.map do |slug|
      person = Person.find_by_slug(slug)
      logger.error "Unable to find Person with slug '#{slug}'", line_number unless person
      person
    end.compact

    people.map do |person|
      ministerial_roles = person.ministerial_roles_at(date)
      logger.error "Unable to find a Role for '#{person.slug}' at '#{date}'", line_number if ministerial_roles.empty?
      ministerial_roles
    end.flatten
  end
end
