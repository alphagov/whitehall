module SyncChecker
  module Formats
    class CorporateInformationPageCheck < EditionBase
      def expected_details_hash(corporate_information_page, _)
        super.tap do |details|
          details.delete(:change_history)
          details.delete(:first_public_at)

          details.merge(
            expected_corporate_information_groups(corporate_information_page)
          ) if corporate_information_page.about_page?

          details.merge(expected_organisation(corporate_information_page))
          details.merge(expected_tags(corporate_information_page))
        end
      end

      def rendering_app
        Whitehall::RenderingApp::WHITEHALL_FRONTEND
      end

      def root_path
        'government/organisations'
      end

      def checks_for_live(_locale)
        super.tap do |checks|
          if edition_expected_in_live.about_page?
            checks << Checks::LinksCheck.new(
              'corporate_information_pages',
              expected_corporate_information_page_content_ids
            )
          end
        end
      end

      def check_live(_response, _locale)
        super unless edition_expected_in_live.worldwide_organisation.present?
      end

      def check_draft(_response, _locale)
        super unless edition_expected_in_draft.worldwide_organisation.present?
      end

    private

      def expected_corporate_information_page_content_ids
        pages = edition_expected_in_live
          .organisation
          .corporate_information_pages
          .published

        [].tap { |ids|
          ids.push(*pages.by_menu_heading(:jobs_and_contracts).map(&:content_id))
          ids.push(*pages.by_menu_heading(:our_information).map(&:content_id))
          ids.push(pages.for_slug('about-our-services').try(:content_id))
          ids.push(pages.for_slug('personal-information-charter').try(:content_id))
          ids.push(pages.for_slug('publication-scheme').try(:content_id))
          ids.push(pages.for_slug('social-media-use').try(:content_id))
          ids.push(pages.for_slug('welsh-language-scheme').try(:content_id))
        }.compact
      end

      def top_level_fields_hash(corporate_information_page, locale)
        super.tap do |fields|
          I18n.with_locale(locale) do
            fields[:document_type] = corporate_information_page.display_type_key
            fields[:title] = corporate_information_page.title
          end
        end
      end

      def expected_tags(corporate_information_page)
        topics = Array(corporate_information_page.primary_specialist_sector_tag) +
          corporate_information_page.secondary_specialist_sector_tags

        {
          'tags' => {
            'browse_pages' => [],
            'policies' => [],
            'topics' => topics.compact,
          }
        }
      end

      def expected_organisation(corporate_information_page)
        {
          organisation: corporate_information_page.organisation.content_id
        }
      end

      def expected_corporate_information_groups(corporate_information_page)
        {
          corporate_information_groups: corporate_information_groups(corporate_information_page)
            .reject { |group| group[:contents].empty? }
        }
      end

      def corporate_information_groups(corporate_information_page)
        [].tap do |groups|
          groups << {
            name: translation_for_group(:access_our_info),
            contents: contents_for_access_our_info(corporate_information_page).compact
          }

          groups << {
            name: translation_for_group(:jobs_and_contacts),
            contents: contents_for_jobs_and_contacts(corporate_information_page).compact
          } unless corporate_information_page.organisation.court_or_hmcts_tribunal?
        end
      end

      def translation_for_group(group, namespace = :corporate_information)
        I18n.t("organisation.#{namespace}.#{group}")
      end

      def contents_for_access_our_info(corporate_information_page)
        [].tap do |contents|
          contents.push(payload_for_organisation_chart(corporate_information_page))
          contents.push(*page_content_ids_by_menu_heading(:our_information, corporate_information_page))
          contents.push(payload_for_corporate_reports(corporate_information_page))
          contents.push(payload_for_transparency_data(corporate_information_page))
        end
      end

      def contents_for_jobs_and_contacts(corporate_information_page)
        [].tap do |contents|
          contents.push(*page_content_ids_by_menu_heading(:jobs_and_contracts, corporate_information_page))
          contents.push(payload_for_jobs(corporate_information_page))
        end
      end

      def page_content_ids_by_menu_heading(menu_heading, corporate_information_page)
        corporate_information_page
          .organisation
          .corporate_information_pages
          .published
          .by_menu_heading(menu_heading)
          .map(&:content_id)
      end

      def organisation_has_corporate_report_publications?(corporate_information_page)
        return unless corporate_information_page.organisation.present?

        corporate_information_page.organisation.has_published_publications_of_type?(
          PublicationType::CorporateReport,
        )
      end

      def organisation_has_chart_url?(corporate_information_page)
        return unless corporate_information_page.organisation.present?

        corporate_information_page.organisation.organisation_chart_url.present?
      end


      def organisation_has_transparency_data_publications?(corporate_information_page)
        return unless corporate_information_page.organisation.present?

        corporate_information_page.organisation.has_published_publications_of_type?(
          PublicationType::TransparencyData,
        )
      end

      def payload_for_corporate_reports(corporate_information_page)
        return unless organisation_has_corporate_report_publications?(corporate_information_page)
        url_maker = Whitehall.url_maker
        corporate_reports_path =
          url_maker
            .publications_filter_path(
              corporate_information_page.organisation,
              publication_type: 'corporate-reports',
            )

        {
          title: translation_for_group(:corporate_reports, :headings),
          path: corporate_reports_path,
        }
      end

      def payload_for_jobs(corporate_information_page)
        {
          title: 'Jobs',
          url: corporate_information_page.organisation.jobs_url,
        }
      end

      def payload_for_organisation_chart(corporate_information_page)
        return unless organisation_has_chart_url?(corporate_information_page)

        {
          title: translation_for_group(:organisation_chart),
          url: corporate_information_page.organisation.organisation_chart_url,
        }
      end

      def payload_for_transparency_data(corporate_information_page)
        return unless organisation_has_transparency_data_publications?(corporate_information_page)

        url_maker = Whitehall.url_maker
        transparency_data_path =
          url_maker
            .publications_filter_path(
              corporate_information_page.organisation,
              publication_type: 'transparency-data',
            )

        {
          title: translation_for_group(:transparency),
          path: transparency_data_path,
        }
      end
    end
  end
end
