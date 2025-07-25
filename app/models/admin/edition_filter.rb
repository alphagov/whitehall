module Admin
  class EditionFilter
    EDITION_TYPE_LOOKUP = Whitehall.edition_classes.index_by(&:to_s)

    MAX_EXPORT_SIZE = 8000
    GOVUK_DESIGN_SYSTEM_PER_PAGE = 15

    attr_reader :options
    attr_accessor :errors

    def initialize(source, current_user, options = {})
      @source = source
      @current_user = current_user
      @options = options
      @errors = []
    end

    def editions(locale = nil)
      @editions ||= {}
      return @editions[locale] if @editions[locale]

      requested_editions = editions_with_translations(locale)
        .page(options[:page])
        .per(options.fetch(:per_page) { default_page_size })

      @editions[locale] = Kaminari.paginate_array(
        permitted_only(requested_editions),
        total_count: requested_editions.total_count,
      ).page(options[:page])
      .per(options.fetch(:per_page) { default_page_size })
    end

    def each_edition_for_csv(locale = nil)
      editions_with_translations(locale).find_each(batch_size: 100) do |edition|
        yield edition if Whitehall::Authority::Enforcer.new(@current_user, edition).can?(:see)
      end
    end

    def page_title
      "#{ownership} #{edition_state} #{type_for_display}#{title_matches}#{location_matches} #{date_range_string} #{review_reminder_string}".squeeze(" ").strip
    end

    def default_page_size
      Kaminari.config.default_per_page
    end

    def hide_type
      options[:hide_type]
    end

    def show_stats
      %w[published].include?(options[:state])
    end

    def published_count
      unpaginated_editions.published.count
    end

    def force_published_count
      unpaginated_editions.force_published.count
    end

    def force_published_percentage
      if published_count.positive?
        ((force_published_count / published_count.to_f) * 100.0).round(2)
      else
        0
      end
    end

    def valid?
      validate_author
      validate_organisation
      validate_date(:from_date)
      validate_date(:to_date)

      errors.empty?
    end

    def from_date
      @from_date ||= Chronic.parse(options[:from_date], endian_precedence: :little, guess: :begin) if options[:from_date]
    end

    def to_date
      @to_date ||= Chronic.parse(options[:to_date], endian_precedence: :little, guess: :begin) if options[:to_date]
    end

    def date_range_string
      if from_date && to_date
        "from #{from_date.to_date.to_fs(:uk_short)} to #{to_date.to_date.to_fs(:uk_short)}"
      elsif from_date
        "from #{from_date.to_date.to_fs(:uk_short)}"
      elsif to_date
        "before #{to_date.to_date.to_fs(:uk_short)}"
      end
    end

    def review_reminder_string
      "with overdue reviews" if review_overdue
    end

    def exportable?
      unpaginated_editions.count <= MAX_EXPORT_SIZE
    end

  private

    def unpaginated_editions
      return @unpaginated_editions if @unpaginated_editions

      editions = @source
      editions = editions.by_type(type) if type
      editions = editions.by_subtype(type, subtype) if subtype
      editions = editions.by_subtypes(type, subtype_ids) if type && subtype_ids
      editions = editions.in_state(state) if state
      editions = editions.authored_by(author) if author
      editions = editions.in_organisation(organisation) if organisation
      editions = editions.with_topical_event(topical_event) if topical_event
      editions = editions.with_title_containing(title) if title
      editions = editions.in_world_location(selected_world_locations) if selected_world_locations.any?
      editions = editions.from_date(from_date) if from_date
      editions = editions.to_date(to_date) if to_date
      editions = editions.only_invalid_editions if only_invalid_editions
      editions = editions.not_validated_since(not_validated_since) if not_validated_since
      editions = editions.only_broken_links if only_broken_links
      editions = editions.review_overdue if review_overdue

      editions = editions.includes(:unpublishing) if include_unpublishing?
      editions = editions.includes(:link_check_report) if include_link_check_report?
      editions = editions.includes(:last_author) if include_last_author?

      @unpaginated_editions = editions
    end

    def editions_with_translations(locale = nil)
      editions_without_translations = unpaginated_editions
                                        .order("editions.updated_at DESC")

      if locale
        editions_without_translations.with_translations(locale)
      else
        editions_without_translations.includes(:translations)
      end
    end

    def permitted_only(requested_editions)
      return requested_editions if Whitehall::Authority::Enforcer.new(@current_user, Edition).can?(:perform_administrative_tasks)

      requested_editions.select do |edition|
        Whitehall::Authority::Enforcer.new(@current_user, edition).can?(:see)
      end
    end

    def state
      options[:state] if Edition.valid_state?(options[:state])
    end

    def title
      options[:title].presence
    end

    def type
      EDITION_TYPE_LOOKUP[options[:type].sub(/_\d+$/, "").classify] if options[:type]
    end

    def subtype
      subtype_class.find_by_id(subtype_id) if type && subtype_id
    end

    def subtype_ids
      options[:subtypes].present? && options[:subtypes]
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
        "#{author.name}’s"
      elsif organisation && organisation == @current_user.organisation
        "My department’s"
      elsif organisation
        organisation.name.possessive
      else
        "Everyone’s"
      end
    end

    def title_matches
      " that match ‘#{options[:title]}’" if options[:title].present?
    end

    def edition_state
      options[:state].humanize.downcase if options[:state].present? && options[:state] != "active"
    end

    def organisation
      Organisation.friendly.find(options[:organisation]) if options[:organisation].present?
    end

    def author
      User.find(options[:author]) if options[:author].present?
    end

    def validate_organisation
      organisation
    rescue ActiveRecord::RecordNotFound
      @errors << "Organisation not found"
    end

    def validate_author
      author
    rescue ActiveRecord::RecordNotFound
      @errors << "Author not found"
    end

    def validate_date(field)
      is_valid = !options[field] || Chronic.parse(options[field], endian_precedence: :little, guess: :begin)
      @errors << "The '#{field.to_s.humanize}' is incorrect. It should be dd/mm/yyyy" unless is_valid
    end

    def topical_event
      TopicalEvent.find(options[:topical_event]) if options[:topical_event].present?
    end

    def not_validated_since
      options[:not_validated_since].presence
    end

    def location_matches
      if selected_world_locations.any?
        sentence = selected_world_locations.map { |l| WorldLocation.friendly.find(l).name }.to_sentence
        " about #{sentence}"
      end
    end

    def only_invalid_editions
      options[:only_invalid_editions].present?
    end

    def only_broken_links
      options[:only_broken_links].present?
    end

    def review_overdue
      options[:review_overdue].present?
    end

    def include_unpublishing?
      options.fetch(:include_unpublishing, false)
    end

    def include_link_check_report?
      options.fetch(:include_link_check_report, false)
    end

    def include_last_author?
      options.fetch(:include_last_author, false)
    end
  end
end
