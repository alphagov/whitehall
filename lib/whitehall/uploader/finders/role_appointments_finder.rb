class Whitehall::Uploader::Finders::RoleAppointmentsFinder
  def self.find(date, *slugs, logger, line_number)
    slugs = slugs.reject { |slug| slug.blank? }

    people = slugs.map do |slug|
      person = Person.find_by_slug(slug)
      logger.error "Unable to find Person with slug '#{slug}'", line_number unless person
      person
    end.compact

    people.map do |person|
      appointments = person.role_appointments_at(date)
      logger.error "Unable to find an appointment for '#{person.slug}' at '#{date}'", line_number if appointments.empty?
      appointments
    end.flatten
  end
end
