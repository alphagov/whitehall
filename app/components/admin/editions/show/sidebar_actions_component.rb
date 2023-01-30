# frozen_string_literal: true

class Admin::Editions::Show::SidebarActionsComponent < ViewComponent::Base
  def initialize(edition:, current_user:)
    @url_maker = Whitehall::UrlMaker.new(host: Plek.find("whitehall"))
    @enforcer = Whitehall::Authority::Enforcer.new(current_user, edition)
    @scheduler = Whitehall.edition_services.scheduler(edition)
    @force_scheduler = Whitehall.edition_services.force_scheduler(edition)
    @publisher = Whitehall.edition_services.publisher(edition)
    @force_publisher = Whitehall.edition_services.force_publisher(edition)

    @edition = edition
  end

  def render?
    actions.any?
  end

  def actions
    unless @actions
      @actions = []
      add_create_action
      add_submit_action
      add_edit_action
      add_unschedule_action
      add_schedule_action
      add_publish_action
      add_reject_action
      add_destroy_action
      add_unwithdraw_action
      add_unpublish_action
      add_view_action
      add_data_action
    end
    @actions
  end

private

  def add_create_action
    if @edition.is_latest_edition? && @edition.published?
      actions << form_with(url: revise_admin_edition_path(@edition.id), method: :post) do
        render("govuk_publishing_components/components/button", {
          text: "Create new edition",
          data_attributes: {
            module: "gem-track-click",
            "track-category": "button-pressed",
            "track-action": "#{dasherized_class_name}-button",
            "track-label": "Create new edition",
          },
        })
      end
    end
  end

  def add_submit_action
    if @edition.can_submit?
      actions << form_with(url: submit_admin_edition_path(@edition, lock_version: @edition.lock_version), method: :post) do
        render("govuk_publishing_components/components/button", {
          text: "Submit for 2nd eyes",
          data_attributes: {
            module: "gem-track-click",
            "track-category": "button-pressed",
            "track-action": "#{dasherized_class_name}-button",
            "track-label": "Submit for 2nd eyes",
          },
        })
      end
    end
  end

  def add_edit_action
    if @edition.editable?
      actions << render("govuk_publishing_components/components/button", {
        text: "Edit draft",
        href: @url_maker.edit_admin_edition_path(@edition),
        secondary_quiet: true,
        data_attributes: {
          module: "gem-track-click",
          "track-category": "button-pressed",
          "track-action": "#{dasherized_class_name}-button",
          "track-label": "Edit draft",
        },
      })
    end
  end

  def add_unschedule_action
    if @edition.can_unschedule? && @enforcer.can?(:update)
      actions << render("govuk_publishing_components/components/button", {
        text: "Unschedule",
        title: "Unschedule this edition to allow changes or prevent automatic publication on #{l @edition.scheduled_publication, format: :long}",
        href: confirm_unschedule_admin_edition_path(@edition, lock_version: @edition.lock_version),
        secondary_quiet: true,
        data_attributes: {
          module: "gem-track-click",
          "track-category": "button-pressed",
          "track-action": "#{dasherized_class_name}-button",
          "track-label": "Unschedule",
        },
      })
    end
  end

  def add_schedule_action
    if @scheduler.can_perform? && @enforcer.can?(:publish)
      actions << form_with(url: schedule_admin_edition_path(@edition, lock_version: @edition.lock_version), method: :post) do
        render("govuk_publishing_components/components/button", {
          text: "Schedule",
          title: "Schedule #{@edition.title} for publication on #{l @edition.scheduled_publication, format: :long}",
          secondary_quiet: true,
          data_attributes: {
            module: "gem-track-click",
            "track-category": "button-pressed",
            "track-action": "#{dasherized_class_name}-button",
            "track-label": "Schedule",
          },
        })
      end
    elsif @force_scheduler.can_perform? && @enforcer.can?(:force_publish)
      actions << render("govuk_publishing_components/components/button", {
        text: "Force schedule",
        title: "Schedule #{@edition.title} for publication on #{l @edition.scheduled_publication, format: :long}",
        href: confirm_force_schedule_admin_edition_path(@edition, lock_version: @edition.lock_version),
        secondary_quiet: true,
        data_attributes: {
          module: "gem-track-click",
          "track-category": "button-pressed",
          "track-action": "#{dasherized_class_name}-button",
          "track-label": "Force schedule",
        },
      })
    end
  end

  def add_publish_action
    if @publisher.can_perform? && @enforcer.can?(:publish)
      actions << form_with(url: publish_admin_edition_path(@edition, lock_version: @edition.lock_version), method: :post) do
        render("govuk_publishing_components/components/button", {
          text: "Publish",
          title: "Publish #{@edition.title}",
          data_attributes: {
            module: "gem-track-click",
            "track-category": "button-pressed",
            "track-action": "#{dasherized_class_name}-button",
            "track-label": "Publish",
          },
        })
      end
    elsif @force_publisher.can_perform? && @enforcer.can?(:force_publish)
      actions << render("govuk_publishing_components/components/button", {
        text: "Force publish",
        title: "Publish #{@edition.title}",
        href: confirm_force_publish_admin_edition_path(@edition, lock_version: @edition.lock_version),
        secondary_quiet: true,
        data_attributes: {
          module: "gem-track-click",
          "track-category": "button-pressed",
          "track-action": "#{dasherized_class_name}-button",
          "track-label": "Force publish",
        },
      })
    end
  end

  def add_reject_action
    if @edition.can_reject? && @enforcer.can?(:reject)
      actions << form_with(url: reject_admin_edition_path(@edition, lock_version: @edition.lock_version), method: :post) do
        render("govuk_publishing_components/components/button", {
          text: "Reject",
          destructive: true,
          data_attributes: {
            module: "gem-track-click",
            "track-category": "button-pressed",
            "track-action": "#{dasherized_class_name}-button",
            "track-label": "Reject",
          },
        })
      end
    end
  end

  def add_destroy_action
    if @edition.can_delete? && @edition.unpublishing.nil?
      actions << link_to(
        "Delete draft",
        confirm_destroy_admin_edition_path(@edition),
        class: "govuk-link gem-link--destructive",
        data: {
          module: "gem-track-click",
          "track-category": "button-clicked",
          "track-action": "#{dasherized_class_name}-button",
          "track-label": "Delete draft",
        },
      )
    end
  end

  def add_unwithdraw_action
    if @enforcer.can?(:unwithdraw) && @edition.can_unwithdraw?
      actions << render("govuk_publishing_components/components/button", {
        text: "Unwithdraw",
        href: confirm_unwithdraw_admin_edition_path(@edition, lock_version: @edition.lock_version),
        secondary_quiet: true,
        data_attributes: {
          module: "gem-track-click",
          "track-category": "button-pressed",
          "track-action": "#{dasherized_class_name}-button",
          "track-label": "Unwithdraw",
        },
      })
    end
  end

  def add_unpublish_action
    if @enforcer.can?(:unpublish)
      if @edition.published?
        actions << render("govuk_publishing_components/components/button", {
          text: "Withdraw or unpublish",
          href: confirm_unpublish_admin_edition_path(@edition, lock_version: @edition.lock_version),
          destructive: true,
          data_attributes: {
            module: "gem-track-click",
            "track-category": "button-pressed",
            "track-action": "#{dasherized_class_name}-button",
            "track-label": "Withdraw or unpublish",
          },
        })
      elsif @edition.unpublishing.present? && @edition.unpublishing.explanation.present?
        actions << link_to(
          "Edit #{helpers.withdrawal_or_unpublishing(@edition)} explanation",
          edit_admin_edition_unpublishing_path(@edition),
          class: "govuk-link",
        )
      end
    end
  end

  def add_view_action
    if @edition.publicly_visible?
      actions << link_to("View on website (opens in new tab)",
                         @url_maker.public_document_url(@edition),
                         class: "govuk-link",
                         target: "_blank",
                         rel: "noopener",
                         data: {
                           module: "gem-track-click",
                           track_category: "external-link-clicked",
                           track_action: @url_maker.public_document_url(@edition),
                           track_label: "View on website",
                         })
    end
  end

  def add_data_action
    if @edition.publicly_visible?
      actions << link_to("View data about page", helpers.content_data_page_data_url(@edition), class: "govuk-link", data: {
        module: "gem-track-click",
        track_category: "external-link-clicked",
        track_action: helpers.content_data_page_data_url(@edition),
        track_label: "View data about page",
      })
    end
  end

  def dasherized_class_name
    @dasherized_class_name ||= @edition.model_name.singular.dasherize
  end
end
