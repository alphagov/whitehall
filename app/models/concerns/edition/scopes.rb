module Edition::Scopes
  extend ActiveSupport::Concern

  included do
    scope :with_title_or_summary_containing,
          lambda { |*keywords|
            pattern = "(#{keywords.map { |k| Regexp.escape(k) }.join('|')})"
            in_default_locale.where("edition_translations.title REGEXP :pattern OR edition_translations.summary REGEXP :pattern", pattern:)
          }

    scope :with_title_containing,
          lambda { |keywords|
            escaped_like_expression = keywords.gsub(/([%_])/, "%" => '\\%', "_" => '\\_')
            like_clause = "%#{escaped_like_expression}%"

            scope = in_default_locale.includes(:document)
            scope
              .where("edition_translations.title LIKE :like_clause", like_clause:)
              .or(scope.where(document: { slug: keywords }))
          }

    scope :in_pre_publication_state, -> { where(state: Edition::PRE_PUBLICATION_STATES) }
    scope :force_published, -> { where(state: "published", force_published: true) }
    scope :not_published, -> { where(state: %w[draft submitted rejected]) }
    scope :without_not_published, -> { where.not(state: %w[draft submitted rejected]) }

    scope :announcements, -> { where(type: Announcement.concrete_descendants.collect(&:name)) }
    scope :consultations, -> { where(type: "Consultation") }
    scope :call_for_evidence, -> { where(type: "CallForEvidence") }
    scope :detailed_guides, -> { where(type: "DetailedGuide") }
    scope :statistical_publications, -> { where("publication_type_id IN (?)", PublicationType.statistical.map(&:id)) }
    scope :non_statistical_publications, -> { where("publication_type_id NOT IN (?)", PublicationType.statistical.map(&:id)) }
    scope :corporate_publications, -> { where(publication_type_id: PublicationType::CorporateReport.id) }
    scope :corporate_information_pages, -> { where(type: "CorporateInformationPage") }
    scope :publicly_visible, -> { where(state: Edition::PUBLICLY_VISIBLE_STATES) }

    scope :future_scheduled_editions, -> { scheduled.where(Edition.arel_table[:scheduled_publication].gteq(Time.zone.now)) }

    scope :latest_edition, -> { joins(:document).where("editions.id = documents.latest_edition_id") }
    scope :live_edition, -> { joins(:document).where("documents.live_edition_id = editions.id") }

    scope :review_overdue,
          lambda {
            joins(document: :review_reminder)
              .where(document: { review_reminders: { review_at: ..Time.zone.today } })
              .where.not(first_published_at: nil)
          }

    scope :alphabetical, lambda { |locale = I18n.locale|
      with_translations(locale).order("edition_translations.title ASC")
    }

    scope :published_before, lambda { |date|
      where(arel_table[:public_timestamp].lteq(date))
    }

    scope :published_after, lambda { |date|
      where(arel_table[:public_timestamp].gteq(date))
    }

    scope :in_chronological_order, lambda {
      order(arel_table[:public_timestamp].asc, arel_table[:document_id].asc)
    }

    scope :in_reverse_chronological_order, lambda {
      ids = pluck(:id)
      Edition
        .unscoped
        .where(id: ids)
        .order(
          arel_table[:public_timestamp].desc,
          arel_table[:document_id].desc,
          arel_table[:id].desc,
        )
    }

    scope :without_editions_of_type, lambda { |*edition_classes|
      where(arel_table[:type].not_in(edition_classes.map(&:name)))
    }

    scope :authored_by, lambda { |user|
      if user&.id
        where(
          "EXISTS (
          SELECT * FROM edition_authors ea_authorship_check
          WHERE
            ea_authorship_check.edition_id=editions.id
            AND ea_authorship_check.user_id=?
          )",
          user.id,
        )
      end
    }

    scope :by_type, lambda { |type|
      where(type: type.to_s)
    }

    scope :by_subtype, lambda { |type, subtype|
      merge(type.by_subtype(subtype))
    }

    scope :by_subtypes, lambda { |type, subtype_ids|
      merge(type.by_subtypes(subtype_ids))
    }

    scope :by_type_or_subtypes, lambda { |type, subtypes|
      if subtypes.nil?
        by_type(type)
      elsif subtypes.empty?
        none
      else
        by_subtypes(type, subtypes.pluck(:id))
      end
    }

    scope :in_world_location, lambda { |world_location|
      joins(:world_locations).where("world_locations.id" => world_location)
    }

    scope :from_date, ->(date) { where("editions.updated_at >= ?", date) }
    scope :to_date, ->(date) { where("editions.updated_at <= ?", date) }

    scope :only_broken_links, lambda {
      joins(
        "
  LEFT JOIN (
    SELECT id, link_reportable_type, link_reportable_id
    FROM link_checker_api_reports
    GROUP BY link_reportable_type, link_reportable_id
    ORDER BY id DESC
  ) AS latest_link_checker_api_reports
    ON latest_link_checker_api_reports.link_reportable_type = 'Edition'
   AND latest_link_checker_api_reports.link_reportable_id = editions.id
   AND latest_link_checker_api_reports.id = (SELECT MAX(id) FROM link_checker_api_reports WHERE link_checker_api_reports.link_reportable_type = 'Edition' AND link_checker_api_reports.link_reportable_id = editions.id)",
      ).where(
        "
  EXISTS (
    SELECT 1
    FROM link_checker_api_report_links
    WHERE link_checker_api_report_id = latest_link_checker_api_reports.id
      AND link_checker_api_report_links.status IN ('broken', 'caution')
  )",
      )
    }

    # NOTE: this scope becomes redundant once Admin::EditionFilterer is backed by an admin-only search_api index
    scope :with_topical_event, lambda { |topical_event|
      joins("INNER JOIN topical_event_memberships ON topical_event_memberships.edition_id = editions.id")
        .where("topical_event_memberships.topical_event_id" => topical_event.id)
    }

    scope :due_for_publication, lambda { |within_time = 0|
      cutoff = Time.zone.now + within_time
      scheduled.where(arel_table[:scheduled_publication].lteq(cutoff))
    }
  end
end
