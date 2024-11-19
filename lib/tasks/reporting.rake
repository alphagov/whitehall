require "ruby-progressbar"

namespace :reporting do
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
      next unless object.attachable.state == "published"

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
