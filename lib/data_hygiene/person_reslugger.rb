module DataHygiene
  # Reslugs a person to new_slug.
  #
  # When run, the following happens:
  #
  #   - updates the Person record's slug
  #   - republishes to Publishing API (which creates a redirect)
  #   - reindexes the person for search
  #   - reindexes all dependent documents in search
  #
  class PersonReslugger
    def initialize(person, new_slug)
      @person = person
      @new_slug = new_slug
      @old_slug = person.slug
    end

    def run!
      update_slug
    end

  private

    attr_reader :person, :new_slug, :old_slug

    def update_slug
      # NOTE: This will trigger calls to the Publishing API.
      person.update!(slug: new_slug)
    end
  end
end
