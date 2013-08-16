module Admin
  class EditionFilter
    attr_reader :options

    def initialize(source, current_user, options={})
      @source, @current_user, @options = source, current_user, options
    end

    def editions
      @editions ||= editions_with_filter.
                      includes(:last_author, :translations).
                      order("editions.updated_at DESC").
                      page(options[:page]).
                      per( options.fetch(:per_page) { default_page_size } )
    end

    def editions_with_filter
      editions = @source
      editions = editions.accessible_to(@current_user)
      editions = editions.by_type(type) if type
      editions = editions.by_subtype(type, subtype) if subtype?
      editions = editions.__send__(options[:state]) if options[:state]
      editions = editions.authored_by(author) if options[:author]
      editions = editions.in_organisation(organisation) if options[:organisation]
      editions = editions.with_title_containing(options[:title]) if options[:title]
      editions = editions.in_world_location(selected_world_locations) if selected_world_locations.any?
      editions = editions.from_date(from_date) if from_date
      editions = editions.to_date(to_date) if to_date
      editions
    end

    def unpagenated_edtions
      @unpagenated_edtions ||= editions_with_filter
    end

    def page_title
      "#{ownership} #{edition_state} #{type_for_display}#{title_matches}#{location_matches}".squeeze(' ')
    end

    def default_page_size
      50
    end

    def type
      if options[:type].present?
        if subtype?
          supertype.classify
        else
          options[:type].classify
        end
      end
    end

    def subtype?
      options[:type].match("_subtype_") if options[:type]
    end

    def supertype
      options[:type].sub(/_subtype_.*/, '') if options[:type]
    end

    def subtype
      options[:type].sub(/.*_subtype_/, '') if options[:type]
    end

    def type_for_display
      if options[:type].present?
        if subtype?
          subtype
        else
          options[:type].humanize.pluralize.downcase
        end
      else
        "documents"
      end
    end

    def show_stats
      ['published'].include?(options[:state])
    end

    def published_count
      unpagenated_edtions.published.count
    end

    def force_published_count
      unpagenated_edtions.force_published.count
    end

    def force_published_percentage
      if published_count > 0
        (( force_published_count.to_f / published_count.to_f) * 100.0).round(2)
      else
        0
      end
    end

    def valid?
      author
      organisation
      true
    rescue ActiveRecord::RecordNotFound
      false
    end

    def from_date
      @from_date ||= Chronic.parse(options[:from_date], endian_precedence: :little) if options[:from_date]
    end

    def to_date
      @to_date ||= Chronic.parse(options[:to_date], endian_precedence: :little) if options[:to_date]
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
      options[:state].humanize.downcase if options[:state] && options[:state] != 'active'
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
