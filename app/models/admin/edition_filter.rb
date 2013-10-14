module Admin
  class EditionFilter
    EDITION_TYPE_LOOKUP = Whitehall.edition_classes.reduce({}) do |lookup, klass|
      lookup[klass.to_s] = klass
      lookup
    end

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
      editions = editions.by_subtype(type, subtype) if subtype
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
      "#{ownership} #{edition_state} #{type_for_display}#{title_matches}#{location_matches} #{date_range_string}".squeeze(' ').strip
    end

    def default_page_size
      50
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

    def date_range_string
      if from_date && to_date
        "from #{from_date.to_date.to_s(:uk_short)} to #{to_date.to_date.to_s(:uk_short)}"
      elsif from_date
        "after #{from_date.to_date.to_s(:uk_short)}"
      elsif to_date
        "before #{to_date.to_date.to_s(:uk_short)}"
      end
    end

    private

    def type
      EDITION_TYPE_LOOKUP[options[:type].sub(/_\d+$/, '').classify] if options[:type]
    end

    def subtype
      subtype_class.find_by_id(subtype_id) if type && subtype_id
    end

    def subtype_id
      if options[:type] && options[:type][/\d+$/]
        options[:type][/\d+$/].to_i
      end
    end

    def subtype_class
      "#{type}Type".constantize
    end

    def type_for_display
      if subtype
        subtype.plural_name.downcase
      elsif type
        type.model_name.human.pluralize.downcase
      else
        "documents"
      end
    end

    def selected_world_locations
      if options[:world_location].blank?
        []
      elsif options[:world_location] == "user"
        @current_user.world_locations
      else
        [options[:world_location]]
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
