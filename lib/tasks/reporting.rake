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
end

def print_result(object)
  puts "#{object.class.name},#{object.content_id},#{object.base_path}"
end
