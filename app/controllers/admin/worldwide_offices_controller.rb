class Admin::WorldwideOfficesController < Admin::BaseController
  before_action :find_worldwide_organisation
  before_action :find_worldwide_office, only: %i[edit update confirm_destroy destroy]
  extend Admin::HomePageListController
  is_home_page_list_controller_for :offices,
                                   redirect_to: ->(container, _item) { admin_worldwide_organisation_worldwide_offices_path(container) }
  def index; end

  def new
    @worldwide_office = @worldwide_organisation.offices.build
    @worldwide_office.build_contact
    @worldwide_office.contact.contact_numbers.build
  end

  def edit
    @worldwide_office.contact.contact_numbers.build unless @worldwide_office.contact.contact_numbers.any?
  end

  def update
    worldwide_office_params[:service_ids] ||= []
    if @worldwide_office.update(worldwide_office_params)
      handle_show_on_home_page_param
      republish_draft_worldwide_organisation
      redirect_to admin_worldwide_organisation_worldwide_offices_path(@worldwide_organisation), notice: "#{@worldwide_office.title} has been edited"
    else
      @worldwide_office.contact.contact_numbers.build if @worldwide_office.contact.contact_numbers.blank?
      render :edit
    end
  end

  def create
    @worldwide_office = @worldwide_organisation.offices.build(worldwide_office_params)
    if @worldwide_office.save
      handle_show_on_home_page_param
      republish_draft_worldwide_organisation
      redirect_to admin_worldwide_organisation_worldwide_offices_path(@worldwide_organisation), notice: "#{@worldwide_office.title} has been added"
    else
      @worldwide_office.contact.contact_numbers.build if @worldwide_office.contact.contact_numbers.blank?
      render :new
    end
  end

  def reorder
    @reorderable_offices = @worldwide_organisation.home_page_offices
  end

  def confirm_destroy; end

  def destroy
    title = @worldwide_office.title

    if @worldwide_office.destroy
      if @worldwide_office.edition
        PublishingApiDiscardDraftWorker.perform_async(@worldwide_office.content_id, I18n.default_locale.to_s)
        PublishingApiDiscardDraftWorker.perform_async(@worldwide_office.contact.content_id, I18n.default_locale.to_s)
      end

      republish_draft_worldwide_organisation
      redirect_to admin_worldwide_organisation_worldwide_offices_path(@worldwide_organisation), notice: "#{title} has been deleted"
    else
      render :edit
    end
  end

private

  def home_page_list_item
    @worldwide_office
  end

  def home_page_list_container
    @worldwide_organisation
  end

  def publish_container_to_publishing_api
    home_page_list_container.try(:publish_to_publishing_api)
  end

  def handle_show_on_home_page_param
    if @show_on_home_page.present?
      case @show_on_home_page
      when "1"
        home_page_list_container.add_office_to_home_page!(home_page_list_item)
      when "0"
        home_page_list_container.remove_office_from_home_page!(home_page_list_item)
      end
    end
  end

  def extract_items_from_ordering_params
    item_ordering = params[:ordering] || {}
    item_ordering.permit!.to_h
      .map { |item_id, ordering| [WorldwideOffice.find_by(id: item_id), ordering.to_i] }
      .sort_by { |_, ordering| ordering }
      .map { |item, _| item }
      .compact
  end

  def extract_show_on_home_page_param
    @show_on_home_page = params[:worldwide_office].delete(:show_on_home_page)
  end

  def find_worldwide_organisation
    @worldwide_organisation = if Flipflop.editionable_worldwide_organisations?
                                Edition.find(params[:worldwide_organisation_id])
                              else
                                WorldwideOrganisation.find(params[:worldwide_organisation_id])
                              end
  end

  def find_worldwide_office
    @worldwide_office = @worldwide_organisation.offices.find(params[:id])
  end

  def worldwide_office_params
    params.require(:worldwide_office)
          .permit(:worldwide_office_type_id,
                  :show_on_home_page,
                  :access_and_opening_times,
                  service_ids: [],
                  contact_attributes: [
                    :id,
                    :title,
                    :contact_type_id,
                    :comments,
                    :recipient,
                    :street_address,
                    :locality,
                    :region,
                    :postal_code,
                    :country_id,
                    :email,
                    :contact_form_url,
                    { contact_numbers_attributes: %i[id label number _destroy] },
                  ])
  end

  def republish_draft_worldwide_organisation
    Whitehall.edition_services.draft_updater(@worldwide_office.edition).perform! if @worldwide_office.edition
  end
end
