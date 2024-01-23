class Admin::ContactsController < Admin::BaseController
  before_action :find_contactable
  before_action :find_contact, only: %i[edit update destroy confirm_destroy]
  before_action :destroy_blank_contact_numbers, only: %i[create update]
  extend Admin::HomePageListController
  is_home_page_list_controller_for :contacts,
                                   item_type: Contact,
                                   redirect_to: ->(container, _item) { [:admin, container, Contact] }

  def index; end

  def new
    @contact = @contactable.contacts.build
    @contact.contact_numbers.build
    render :new
  end

  def edit
    @contact.contact_numbers.build unless @contact.contact_numbers.any?
    render :edit
  end

  def update
    if @contact.update(contact_params)
      handle_show_on_home_page_param
      redirect_to [:admin, @contact.contactable, Contact], notice: %("#{@contact.title}" updated successfully)
    else
      @contact.contact_numbers.build if @contact.contact_numbers.blank?
      render :edit
    end
  end

  def create
    @contact = @contactable.contacts.build(contact_params)
    if @contact.save
      handle_show_on_home_page_param
      redirect_to [:admin, @contact.contactable, Contact], notice: %("#{@contact.title}" created successfully)
    else
      @contact.contact_numbers.build if @contact.contact_numbers.blank?
      render :new
    end
  end

  def confirm_destroy; end

  def destroy
    title = @contact.title
    if @contact.destroy
      redirect_to [:admin, @contact.contactable, Contact], notice: %("#{title}" deleted successfully)
    else
      render :edit
    end
  end

  def reorder; end

private

  def home_page_list_item
    @contact
  end

  def home_page_list_container
    @contactable
  end

  def publish_container_to_publishing_api
    home_page_list_container.publish_to_publishing_api
  end

  def handle_show_on_home_page_param
    if @show_on_home_page.present?
      case @show_on_home_page
      when "1"
        home_page_list_container.add_contact_to_home_page!(home_page_list_item)
      when "0"
        home_page_list_container.remove_contact_from_home_page!(home_page_list_item)
      end
    end
  end

  def extract_show_on_home_page_param
    @show_on_home_page = params[:contact].delete(:show_on_home_page)
  end

  def find_contactable
    @contactable = Organisation.friendly.find(params[:organisation_id])
  end

  def find_contact
    @contact = @contactable.contacts.find(params[:id])
  end

  def destroy_blank_contact_numbers
    (params[:contact][:contact_numbers_attributes] || {}).each_pair do |_key, attributes|
      if attributes.except(:id).values.all?(&:blank?)
        attributes[:_destroy] = "1"
      end
    end
  end

  def contact_params
    params.require(:contact)
          .permit(:title,
                  :comments,
                  :recipient,
                  :street_address,
                  :locality,
                  :region,
                  :postal_code,
                  :country_id,
                  :email,
                  :contact_form_url,
                  :contact_type_id,
                  contact_numbers_attributes: %i[id label number _destroy])
  end
end
