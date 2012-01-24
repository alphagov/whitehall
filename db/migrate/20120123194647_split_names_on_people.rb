class SplitNamesOnPeople < ActiveRecord::Migration
  class Person < ActiveRecord::Base
  end

  NAME_PATTERN = /^
    (
      .*                                                            # title prefix (e.g. "The")
      \b(?:Baroness|Dame|Dr|Earl|General|Hon|Lord|Professor|Sir)\b  # title
    )?
    \s*
    (.+?)                                                           # personal name
    \s*
    ((?:(?:[[:upper:]]+|Bt)\s*)*)                                   # letters ("Bt" means "Baronet")
  $/x

  def up
    name_parts = {}

    Person.all.map(&:name).each do |name|
      if match = NAME_PATTERN.match(name)
        title, personal_name, letters = match.captures

        personal_names = personal_name.split(/\s+/)
        forename = personal_names.shift unless personal_names.one? || personal_names.second == 'of'
        surname = personal_names.join(' ')

        name_parts[name] = { title: title, forename: forename, surname: surname, letters: letters }
      else
        raise "couldn't split \"#{name}\""
      end
    end

    change_table :people do |t|
      t.string :title, after: :name
      t.string :forename, after: :title
      t.string :surname, after: :forename
      t.string :letters, after: :surname
    end

    Person.reset_column_information

    Person.record_timestamps = false
    Person.all.each do |person|
      person.update_attributes! name_parts[person.name]
    end
    Person.record_timestamps = true

    change_table :people do |t|
      t.remove :name
    end
  end

  def down
    change_table :people do |t|
      t.string :name, after: :letters
    end

    Person.reset_column_information

    Person.record_timestamps = false
    Person.all.each do |person|
      person.update_attributes! name: [:title, :forename, :surname, :letters].map(&person.method(:send)).compact.join(' ')
    end
    Person.record_timestamps = true

    change_table :people do |t|
      t.remove :title
      t.remove :forename
      t.remove :surname
      t.remove :letters
    end
  end
end