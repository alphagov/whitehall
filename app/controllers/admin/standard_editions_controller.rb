# Trying to figure out how configurable document types work? Check the documentation: `docs/configurable_document_types.md`!
class Admin::StandardEditionsController < Admin::EditionsController
  rescue_from ConfigurableDocumentType::NotFoundError, with: :render_not_found

  before_action :set_current_tab_context, only: %i[edit update]

  def choose_type
    @permitted_configurable_document_types = ConfigurableDocumentType.where_group(params[:group])
                                                                     .select { |type| can?(current_user, type) }

    render_not_found if @permitted_configurable_document_types.empty?
  end

  def change_type
    find_edition

    @available_types = ConfigurableDocumentType.convertible_from(@edition.configurable_document_type)
      .select { |type| can?(current_user, type) }
  end

  def change_type_preview
    find_edition

    new_type_id = params.fetch(:configurable_document_type)
    @old_type = ConfigurableDocumentType.find(@edition.configurable_document_type)
    @new_type = ConfigurableDocumentType.find(new_type_id)
  end

  def apply_change_type
    find_edition
    new_type_id = params.fetch(:configurable_document_type)

    if @edition.update_configurable_document_type(new_type_id)
      redirect_to admin_standard_edition_path(@edition), notice: "Document type changed successfully."
    else
      redirect_to change_type_preview_admin_standard_edition_path(@edition, configurable_document_type: new_type_id), alert: "Could not change document type."
    end
  end

  # TODO: should this transaction complexity be encapsulated in an EditionService call?
  # That seems to be how we handle this sort of thing elsewhere.
  def create
    success =
      if updater.can_perform?
        begin
          ActiveRecord::Base.transaction do
            @edition.save!
            attach_to_parent_if_this_is_a_child!
            updater.perform!
          end
          true
        rescue ActiveRecord::RecordInvalid => e
          @edition.errors.merge!(e.record.errors)
          false
        end
      end

    if success
      redirect_to show_or_edit_path, saved_confirmation_notice
    else
      build_edition_dependencies
      render :new
    end
  end

  def update
    @edition.current_tab_context = @current_tab_context
    super
  end

  def features
    @feature_list = @edition.load_or_create_feature_list(params[:locale])
    @locale = Locale.new(params[:locale] || :en)

    return render_not_found unless @edition.translations.pluck(:locale).include?(@locale.code.to_s)

    filter_params = params.slice(:page, :type, :author, :organisation, :title)
                          .permit!
                          .to_h
                          .merge(
                            page_title: "GOV.UK content tagged to this topical event",
                            state: "published",
                            linked_document: @edition.document,
                            per_page: Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE,
                            feature_list: @feature_list,
                          )

    @filter = Admin::EditionFilter.new(Edition, current_user, filter_params)
    @tagged_editions = @filter.editions(@feature_list.locale)
    @featurable_offsite_links = @edition.offsite_links
    render :features
  end

private

  def edition_class
    StandardEdition
  end

  def new_edition_params
    # Set the configurable document type for new editions based on the value from the query parameter submitted with the 'choose_type' form
    super[:configurable_document_type].blank? ? super.merge(configurable_document_type: params[:configurable_document_type]) : super
  end

  def set_current_tab_context
    tab_key = params[:current_tab].presence
    @current_tab_context = tab_key if @edition.valid_tab_key?(tab_key)
  end

  def show_or_edit_path
    if params[:save].present? && @current_tab_context.present?
      edit_admin_standard_edition_path(@edition, current_tab: @current_tab_context)
    else
      super
    end
  end

  def render_not_found
    render "admin/errors/not_found", status: :not_found
  end

  def attach_to_parent_if_this_is_a_child!
    parent_id = params[:parent_edition_id].presence
    return unless parent_id

    parent = Edition.find(parent_id)
    enforce_permission!(:update, parent)

    parent.with_lock do
      ParentChildRelationship.create!(
        parent_edition: parent,
        child_document: @edition.document,
      )
    end
  end
end
