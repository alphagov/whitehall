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
      scope.merge(date_and_order_scope)
    end

    def title
      "#{possessive_owner_name} statistics announcements"
    end

    def description
      [date_based_description, additional_filters_description].compact.join(" ")
    end

    delegate :total_count, to: :statistics_announcements

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
        "#{pluralized_count('statistics announcement')} in the past"
      when "imminent"
        "#{pluralized_count('statistics release')} due in two weeks"
      else
        pluralized_count("statistics announcement")
      end
    end

    def additional_filters_description
      if unlinked_only?
        "(without a publication)"
      end
    end

    def unfiltered_scope
      StatisticsAnnouncement.includes(:current_release_date, publication: :translations, organisations: :translations)
                            .joins(:current_release_date)
                            .distinct
                            .page(options[:page])
                            .per(options[:per_page])
    end

    def unlinked_scope
      StatisticsAnnouncement.where("publication_id is NULL")
    end

    def date_and_order_scope
      case options[:dates]
      when "past"
        StatisticsAnnouncement.where("statistics_announcement_dates.release_date < ?", Time.zone.now)
                              .order("statistics_announcement_dates.release_date DESC")
      when "future"
        StatisticsAnnouncement.where("statistics_announcement_dates.release_date > ?", Time.zone.now)
                              .order("statistics_announcement_dates.release_date ASC")
      when "imminent"
        StatisticsAnnouncement.where("statistics_announcement_dates.release_date > ? AND statistics_announcement_dates.release_date < ?", Time.zone.now, 2.weeks.from_now)
                              .order("statistics_announcement_dates.release_date ASC")
      else
        StatisticsAnnouncement.order("statistics_announcement_dates.release_date DESC")
      end
    end
  end
end
