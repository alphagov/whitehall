module Admin
  class StatisticsAnnouncementFilter

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def statistics_announcements
      scope = unfiltered_scope
      scope = scope.with_title_containing(options[:title]) if options[:title].present?
      scope = scope.in_organisations([options[:organisation_id]]) if options[:organisation_id].present?
      scope = scope.merge( unlinked_scope ) if unlinked_only?
      scope = scope.merge( date_and_order_scope )
      scope
    end

    def title
      "#{possessive_owner_name} statistics announcements"
    end

    def description
      [date_based_description, additonal_filters_description].compact.join(' ')
    end

    def total_count
      statistics_announcements.total_count
    end

  private

    def unlinked_only?
      options[:unlinked_only] == "1"
    end

    def organisation
      @organisation ||= Organisation.find_by_id(options[:organisation_id])
    end

    def user
      @user ||= User.find_by_id(options[:user_id])
    end

    def possessive_owner_name
      if organisation.nil?
        "Everyone’s"
      elsif user.try(:organisation) == organisation
        "My organisation’s"
      else
        possessive(organisation.name)
      end
    end

    def possessive(thing_name)
      if thing_name.ends_with?("s")
        "#{thing_name}’"
      else
        "#{thing_name}’s"
      end
    end

    def date_based_description
      case options[:dates]
      when "future"
        "#{total_count} statistics releases due"
      when "past"
        "#{total_count} statistics released"
      when "imminent"
        "#{total_count} statistics releases due in two weeks"
      else
        "#{total_count} statistics announcements"
      end
    end

    def additonal_filters_description
      if unlinked_only?
        "(without a publication)"
      end
    end

    def unfiltered_scope
      StatisticsAnnouncement.includes(:current_release_date, :topics, publication: :translations, organisations: :translations)
                            .joins(:current_release_date)
                            .page(options[:page])
    end

    def unlinked_scope
      StatisticsAnnouncement.where("publication_id is NULL")
    end

    def date_and_order_scope
      case options[:dates]
      when 'past'
        StatisticsAnnouncement.where("release_date < ?", Time.zone.now)
                              .order("release_date DESC")
      when 'future'
        StatisticsAnnouncement.where("release_date > ?", Time.zone.now)
                              .order("release_date ASC")
      when 'imminent'
        StatisticsAnnouncement.where("release_date > ? AND release_date < ?", Time.zone.now, 2.weeks.from_now)
                              .order("release_date ASC")
      else
        StatisticsAnnouncement.order("release_date DESC")
      end
    end
  end
end
