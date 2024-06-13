module Admin::EditionsHelper
  def edition_type(edition)
    if edition.has_parent_type?
      type = if edition.is_a?(Speech) && edition.speech_type.written_article?
               edition.speech_type.singular_name
             else
               edition.type.underscore.humanize
             end

      [type, edition.display_type].compact.uniq.join(": ")
    else
      edition.display_type
    end
  end

  def admin_organisation_filter_options(selected_organisation)
    organisations = Organisation.with_translations(:en).order(:name).excluding_govuk_status_closed || []
    closed_organisations = Organisation.with_translations(:en).closed || []
    if current_user.organisation
      organisations = [current_user.organisation] + (organisations - [current_user.organisation])
    end

    [
      [
        "",
        [
          {
            text: "All organisations",
            value: "",
            selected: selected_organisation.blank?,
          },
        ],
      ],
      [
        "Live organisations",
        organisations.map do |organisation|
          {
            text: organisation.select_name,
            value: organisation.id,
            selected: selected_organisation.to_s == organisation.id.to_s,
          }
        end,
      ],
      [
        "Closed organisations",
        closed_organisations.map do |organisation|
          {
            text: organisation.select_name,
            value: organisation.id,
            selected: selected_organisation.to_s == organisation.id.to_s,
          }
        end,
      ],
    ]
  end

  def admin_author_filter_options(current_user)
    other_users = User.enabled.to_a - [current_user]
    [["All authors", ""], ["Me (#{current_user.name})", current_user.id]] + other_users.map { |u| [u.name, u.id] }
  end

  def admin_state_filter_options
    [
      ["All states", "active"],
      %w[Draft draft],
      %w[Submitted submitted],
      %w[Rejected rejected],
      %w[Scheduled scheduled],
      %w[Published published],
      ["Force published (not reviewed)", "force_published"],
      %w[Withdrawn withdrawn],
      %w[Unpublished unpublished],
    ]
  end

  def admin_world_location_filter_options(current_user)
    options = [["All locations", ""]]
    if current_user.world_locations.any?
      options << ["My locations", "user"]
    end
    options + WorldLocation.ordered_by_name.map { |l| [l.name, l.id] }
  end

  # Because of the unusual way lead organisations and supporting organisations
  # are managed through the single has_many through :organisations association,
  # We have to go through the join model to identify selected organisations
  # when rendering editions' organisation select fields. See the
  # Edition::Organisations mixin module to see why this is required.
  def lead_organisation_id_at_index(edition, index)
    edition.edition_organisations
            .select(&:lead?)
            .sort_by(&:lead_ordering)[index].try(:organisation_id)
  end

  def standard_edition_form(edition)
    form_for form_url_for_edition(edition), as: :edition, html: { class: edition_form_classes(edition), multipart: true }, data: { module: "EditionForm LocaleSwitcher Ga4ButtonSetup", "rtl-locales": Locale.right_to_left.collect(&:to_param) } do |form|
      concat render("standard_fields", form:, edition:)
      yield(form)
      concat render("settings_fields", form:, edition:)
      concat standard_edition_publishing_controls(form, edition)
    end
  end

  def edition_form_classes(edition)
    form_classes = ["edition-form js-edition-form"]
    form_classes << "js-supports-non-english" if edition.locale_can_be_changed?
    form_classes
  end

  def form_url_for_edition(edition)
    if edition.is_a? CorporateInformationPage
      [:admin, edition.owning_organisation, edition]
    else
      [:admin, edition]
    end
  end

  def tab_url_for_edition(edition)
    if edition.is_a? CorporateInformationPage
      if edition.new_record?
        url_for([:new, :admin, edition.owning_organisation, edition.class.model_name.param_key.to_sym])
      else
        url_for([:edit, :admin, edition.owning_organisation, edition])
      end
    elsif edition.new_record?
      url_for([:new, :admin, edition.class.model_name.param_key.to_sym])
    else
      url_for([:edit, :admin, edition])
    end
  end

  def standard_edition_publishing_controls(form, edition)
    tag.div(class: "publishing-controls") do
      if edition.change_note_required?
        concat render("change_notes", form:, edition:)
      end

      concat render("save_or_continue_or_cancel", form:, edition:)
    end
  end

  def warn_about_lack_of_contacts_in_body?(edition)
    if edition.is_a?(NewsArticle) && edition.news_article_type == NewsArticleType::PressRelease
      govspeak_embedded_contacts(edition.body).empty?
    else
      false
    end
  end

  def withdrawal_or_unpublishing(edition)
    edition.unpublishing.unpublishing_reason_id == UnpublishingReason::Withdrawn.id ? "withdrawal" : "unpublishing"
  end

  def show_similar_slugs_warning?(edition)
    !edition.document.live? && edition.document.similar_slug_exists?
  end

  def edition_is_a_novel?(edition)
    edition.body.split.size > 99_999
  end

  def edition_has_links?(edition)
    LinkCheckerApiService.has_links?(edition, convert_admin_links: false)
  end

  def show_link_check_report?(edition)
    # There is an edition that is over 200000 words long.
    # This causes timeouts when LinkCheckerApiService tries to extract links from the body.
    # This is an exceptional case, but it stops publishers editing their editions.
    # Short circuit the call to LinkCheckerApiService by testing for an edition being
    # over 99999 words long. The number was chosen because Wikipedia suggests 100000 words is
    # the lower length of a novel (https://en.wikipedia.org/wiki/Word_count#In_fiction).
    # Returning true from the first half of the "or" means the second half doesn't get computed.
    edition_is_a_novel?(edition) || edition_has_links?(edition)
  end

  def status_text(edition)
    if edition.unpublishing.present?
      "#{edition.state.capitalize} (unpublished #{time_ago_in_words(edition.unpublishing.created_at)} ago)"
    else
      edition.state.capitalize
    end
  end

  def reset_search_fields_query_string_params(user, filter_action, anchor)
    query_string_params = if user.organisation.present? && filter_action == admin_editions_path
                            "?state=active&organisation=#{user.organisation.id}"
                          else
                            "?state=active"
                          end

    filter_action + query_string_params + anchor
  end

  def search_results_table_actions(edition)
    actions = ""
    if can?(:see, edition)
      actions << link_to(
        sanitize("View #{tag.span(edition.title, class: 'govuk-visually-hidden')}"),
        admin_edition_path(edition),
        class: "govuk-link",
      )
    end

    if can?(:perform_administrative_tasks, Edition) && edition.access_limited
      actions << link_to(
        sanitize("Edit access #{tag.span("for #{edition.title}", class: 'govuk-visually-hidden')}"),
        edit_access_limited_admin_edition_path(edition),
        class: "govuk-link",
      )
    end

    sanitize(actions)
  end
end
