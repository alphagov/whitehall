require "gds_api/test_helpers/content_store"

module PersonHelper
  include GdsApi::TestHelpers::ContentStore

  def create_person(name, attributes = {})
    person = create(:person, split_person_name(name).merge(attributes))
    content_store_has_item(person.search_link)
    person
  end

  def find_person(name)
    Person.where(split_person_name(name)).first
  end

  def find_or_create_person(name)
    find_person(name) || create_person(name)
  end

  def fill_in_person_name(name)
    name_parts = split_person_name(name)
    fill_in "Title", with: name_parts[:title]
    fill_in "Forename", with: name_parts[:forename]
    fill_in "Surname", with: name_parts[:surname]
    fill_in "Letters", with: name_parts[:letters]
  end

  def person_image_path
    page.find(".person img")[:src]
  end

  def visit_people_admin
    visit admin_root_path
    click_link "People"
  end

  def add_translation_to_person(person, translation)
    translation = translation.stringify_keys
    visit admin_person_path(person)
    click_link "Translations"
    select translation["locale"], from: "Locale"
    click_on "Create translation"
    fill_in "Biography", with: translation["biography"]
    click_on "Save"
  end

private

  def split_person_name(name)
    if (match = /^(\w+)\s*(.*?)$/.match(name))
      forename, surname = match.captures
      { title: nil, forename: forename, surname: surname, letters: nil }
    else
      raise "couldn't split \"#{name}\""
    end
  end
end

World(PersonHelper)
