module PersonHelper
  def create_person(name)
    create(:person, split_person_name(name))
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

  private
    def split_person_name(name)
      if match = /^(\w+)\s*(.*?)$/.match(name)
        forename, surname = match.captures
        { title: nil, forename: forename, surname: surname, letters: nil }
      else
        raise "couldn't split \"#{name}\""
      end
    end
end

World(PersonHelper)
