module Admin
  class EditionFilter
    attr_reader :options

    def initialize(source, current_user, options={})
      @source, @current_user, @options = source, current_user, options
    end

    def editions
      @editions ||= (
        editions = @source
        editions = editions.accessible_to(@current_user)
        editions = editions.by_type(options[:type].classify) if options[:type]
        editions = editions.__send__(options[:state]) if options[:state]
        editions = editions.authored_by(author) if options[:author]
        editions = editions.in_organisation(organisation) if options[:organisation]
        editions = editions.with_title_containing(options[:title]) if options[:title]
        editions = editions.in_world_location(selected_world_locations) if selected_world_locations.any?
        editions.includes(:last_author, :translations).order("editions.updated_at DESC")
      ).page(options[:page]).per(page_size)
    end

    def page_title
      "#{ownership} #{edition_state} #{document_type.humanize.pluralize.downcase}#{title_matches}#{location_matches}".squeeze(' ')
    end

    def page_size
      50
    end

    def valid?
      author
      organisation
      true
    rescue ActiveRecord::RecordNotFound
      false
    end

    private

    def selected_world_locations
      if options[:world_location_ids] == "all" || options[:world_location_ids].blank?
        []
      else
        options[:world_location_ids]
      end
    end

    def ownership
      if author && author == @current_user
        "My"
      elsif author
        "#{author.name}'s"
      elsif organisation && organisation == @current_user.organisation
        "My department's"
      elsif organisation
        "#{organisation.name}'s"
      else
        "Everyone's"
      end
    end

    def title_matches
      " that match '#{options[:title]}'" if options[:title]
    end

    def edition_state
      options[:state] unless options[:state] == 'active'
    end

    def document_type
      options[:type].present? ? options[:type] : 'document'
    end

    def organisation
      Organisation.find(options[:organisation]) if options[:organisation]
    end

    def author
      User.find(options[:author]) if options[:author]
    end

    def location_matches
      if selected_world_locations.any?
        " about #{selected_world_locations.map { |location| WorldLocation.find(location).name }.to_sentence}"
      end
    end
  end
end
