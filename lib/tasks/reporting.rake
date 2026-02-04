namespace :reporting do
  # The following Rake task might not work out of the box. Known issues include:
  # - MySQL regex timeouts. The guidance for this Rake task in the developer
  #   docs covers this: https://docs.publishing.service.gov.uk/manual/find-usage-of-govspeak-in-content.html#searching-for-raw-govspeak-in-whitehall
  #
  # - Missing associations. The `print_result` method might error if fields
  #   like `base_path` or `slug` (which is often used to build the base path)
  #   are delegated to an associated model, and the associated instance has a
  #   state of `deleted`
  #
  #   You can work around this by editing the model, for example in
  #   `ConsultationResponse`, allowing nil on a delegated method:
  #
  #   `delegate :slug, to: :consultation, allow_nil: true`
  #
  #   Or in `WorldwideOffice`, unscoping the edition association so that deleted
  #   editions can be found:
  #
  #   `belongs_to :edition, -> { unscope(:where) }`
  desc "Prints a list of content IDs for documents whose govspeak content contains a given regular expression"
  task :matching_docs, [:regex] => :environment do |_, args|
    regex = Regexp.new(/#{args[:regex]}/).to_s

    Edition
    .where(state: "published")
    .joins("RIGHT JOIN edition_translations ON edition_translations.edition_id = editions.id")
    .where("body REGEXP ?", regex)
    .find_each do |object|
      print_result(object)
    end

    HtmlAttachment
    .joins(:govspeak_content)
    .where(deleted: false)
    .where.not(attachable: nil)
    .where("govspeak_contents.body REGEXP ?", regex)
    .find_each do |object|
      # Attachables include non-editionable content which doesn't have a state
      next if object.attachable.respond_to?(:state) && object.attachable.state != "published"

      print_result(object)
    end

    Person
    .joins("RIGHT JOIN person_translations ON person_translations.person_id = people.id")
    .where("biography REGEXP ?", regex)
    .find_each do |object|
      print_result(object)
    end

    PolicyGroup
    .where("description REGEXP ?", regex)
    .find_each do |object|
      print_result(object)
    end

    WorldLocationNews
    .joins("RIGHT JOIN world_location_news_translations ON world_location_news_translations.world_location_news_id = world_location_news.id")
    .where("mission_statement REGEXP ?", regex)
    .find_each do |object|
      print_result(object)
    end

    WorldwideOffice
    .where("access_and_opening_times REGEXP ?", regex)
    .find_each do |object|
      print_result(object)
    end
  end

  desc "Prints a report of all 'invalid editions', broken down by edition state"
  task invalid_editions: :environment do
    scope = Edition.only_invalid_editions
    report_invalid_editions(scope)
  end

  desc "Prints a report of all 'invalid editions' created since a certain date (e.g. '2015-05-08'), broken down by edition state"
  task :invalid_editions_created_since, [:from_date] => :environment do |_, args|
    scope = Edition.only_invalid_editions
      .where("created_at > ?", Time.zone.parse(args[:from_date]).iso8601)
    report_invalid_editions(scope)
  end
end

def print_result(object)
  puts "#{object.class.name},#{object.content_id},#{object.base_path}"
end

def classify_error(error)
  case error
  when /Contact ID \d+ doesn't exist/
    # There is one error per Contact ID - so we need to group under the following string
    "Invalid Contact ID"
  when /Excluded nations (can not exclude all nations|is invalid)|Alternative URL for excluded nation is not valid./
    # There are a few different nation-related validation messages, which we'd rather group together for reporting purposes
    "Invalid nations applicability settings"
  else
    error
  end
end

def grouped_and_sorted_invalid_editions(editions)
  editions
    .flat_map { |edition_id, _state, errors| errors.map { |error| [classify_error(error), edition_id] } }
    .group_by(&:first)
    .transform_values { |pairs|
      ids = pairs.map(&:last).uniq
      { ids: ids, count: ids.size }
  }
    .sort_by { |error, data| [-data[:count], error.to_s] }
end

def summarise_invalid_editions(prefix, scope)
  sum_without_duplicates = scope.flat_map { |_, data| data[:ids] }.uniq.count
  puts "#{prefix} (#{sum_without_duplicates})"
  puts "-------------------------------"
  scope.each do |error, hash|
    puts "#{hash[:count]} editions have the error `#{error}`. Example edition IDs: #{hash[:ids].first(10).sort.join(', ')}"
  end
  puts "" # newline
end

def report_invalid_editions(scope)
  puts "Found #{scope.count} invalid editions. Analysing (this could take a few minutes)..."
  editions = scope.map do |ed|
    ed.valid?(:publish)
    [ed.id, ed.state, ed.errors.map(&:full_message)]
  end

  summarise_invalid_editions(
    "All invalid editions",
    grouped_and_sorted_invalid_editions(editions),
  )
  summarise_invalid_editions(
    "Invalid published editions",
    grouped_and_sorted_invalid_editions(editions.select { |ed| ed[1] == "published" }),
  )
  summarise_invalid_editions(
    "Invalid withdrawn editions",
    grouped_and_sorted_invalid_editions(editions.select { |ed| ed[1] == "withdrawn" }),
  )
end
