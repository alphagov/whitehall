module PersonHelper
  def create_person(name)
    create(:person, name: name)
  end

  def find_person(name)
    Person.find_by_name!(name)
  end

  def find_or_create_person(name)
    Person.find_or_create_by_name(name)
  end

  def fill_in_person_name(name)
    fill_in "Name", with: name
  end
end

World(PersonHelper)
