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
      scope = scope.merge( unlinked_scope ) if options[:unlinked_only] == "1"
      scope = scope.merge( date_and_order_scope )
      scope
    end

    def title
      "#{possessive_owner_name} statistics announcements"
    end

  private

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
      when 'four-weeks'
        StatisticsAnnouncement.where("release_date > ? AND release_date < ?", Time.zone.now, 4.weeks.from_now)
                              .order("release_date ASC")
      else
        StatisticsAnnouncement.order("release_date DESC")
      end
    end
  end
end
