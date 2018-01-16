module Admin
  class StatisticsAnnouncementFilter
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::NumberHelper

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def statistics_announcements
      scope = unfiltered_scope
      scope = scope.with_title_containing(options[:title]) if options[:title].present?
      scope = scope.in_organisations([options[:organisation_id]]) if options[:organisation_id].present?
      scope = scope.merge(unlinked_scope) if unlinked_only?
      scope = scope.merge(date_and_order_scope)
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
      @organisation ||= Organisation.find_by(id: options[:organisation_id])
    end

    def user
      @user ||= User.find_by(id: options[:user_id])
    end

    def possessive_owner_name
      if organisation.nil?
        "Everyone’s"
      elsif user.try(:organisation) == organisation
        "My organisation’s"
      else
        organisation.name.possessive
      end
    end

    def pluralized_count(singular)
      pluralize(number_with_delimiter(total_count), singular)
    end

    def date_based_description
      case options[:dates]
      when "future"
        pluralized_count("upcoming statistics release")
      when "past"
        pluralized_count("statistics announcement") + " in the past"
      when "imminent"
        pluralized_count("statistics release") + " due in two weeks"
      else
        pluralized_count("statistics announcement")
      end
    end

    def additonal_filters_description
      if unlinked_only?
        "(without a publication)"
      end
    end

    # DID YOU MEAN: Policy Area?
    # "Policy area" is the newer name for "topic"
    # (https://www.gov.uk/government/topics)
    # "Topic" is the newer name for "specialist sector"
    # (https://www.gov.uk/topic)
    # You can help improve this code by renaming all usages of this field to use
    # the new terminology.
    def unfiltered_scope
      # We are doing a "greatest n by group" query here, but on a joined model,
      # i.e. the StatisticsAnnouncementDate, or in this case the
      # :current_release_date, which is the most recent one. The JOINs and the
      # GROUP combine to ensure the correct things are loaded and in the correct
      # order.
      StatisticsAnnouncement.includes(:current_release_date, statistics_announcement_topics: :topic, publication: :translations, organisations: :translations)
                            .joins("INNER JOIN statistics_announcement_dates
                              ON (statistics_announcement_dates.statistics_announcement_id = statistics_announcements.id)")
                            .joins("LEFT OUTER JOIN statistics_announcement_dates sd2
                              ON (sd2.statistics_announcement_id = statistics_announcements.id
                              AND statistics_announcement_dates.created_at > sd2.created_at)")
                            .group('statistics_announcement_dates.statistics_announcement_id')
                            .page(options[:page])
    end

    def unlinked_scope
      StatisticsAnnouncement.where("publication_id is NULL")
    end

    def date_and_order_scope
      case options[:dates]
      when 'past'
        StatisticsAnnouncement.where("statistics_announcement_dates.release_date < ?", Time.zone.now)
                              .order("statistics_announcement_dates.release_date DESC")
      when 'future'
        StatisticsAnnouncement.where("statistics_announcement_dates.release_date > ?", Time.zone.now)
                              .order("statistics_announcement_dates.release_date ASC")
      when 'imminent'
        StatisticsAnnouncement.where("statistics_announcement_dates.release_date > ? AND statistics_announcement_dates.release_date < ?", Time.zone.now, 2.weeks.from_now)
                              .order("statistics_announcement_dates.release_date ASC")
      else
        StatisticsAnnouncement.order("statistics_announcement_dates.release_date DESC")
      end
    end
  end
end
