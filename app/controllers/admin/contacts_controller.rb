class Admin::ContactsController < Admin::BaseController
  before_action :find_contactable
  before_action :find_contact, only: %i[edit update destroy remove_from_home_page add_to_home_page]
  before_action :destroy_blank_contact_numbers, only: %i[create update]

  def index; end

  def new
    @contact = @contactable.contacts.build
    @contact.contact_numbers.build
  end

  def edit
    @contact.contact_numbers.build unless @contact.contact_numbers.any?
  end

  def update
    @contact.update(contact_params)
    if @contact.save
      handle_show_on_home_page_param
      redirect_to [:admin, @contact.contactable, Contact], notice: %{"#{@contact.title}" updated successfully}
    else
      render :edit
    end
  end

  def create
    @contact = @contactable.contacts.build(contact_params)
    if @contact.save
      handle_show_on_home_page_param
      redirect_to [:admin, @contact.contactable, Contact], notice: %{"#{@contact.title}" created successfully}
    else
      render :edit
    end
  end

  def destroy
    title = @contact.title
    if @contact.destroy
      redirect_to [:admin, @contact.contactable, Contact], notice: %{"#{title}" deleted successfully}
    else
      render :edit
    end
  end

  extend Admin::HomePageListController
  is_home_page_list_controller_for :contacts,
                                   item_type: Contact,
                                   contained_by: :contactable,
                                   redirect_to: ->(container, _item) { [:admin, container, Contact] }

private

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

  def handle_show_on_home_page_param
    if @contactable.respond_to?(:home_page_contacts)
      super
    end
  end

  def contact_params
    params.require(:contact)
          .permit(:title, :comments, :recipient, :street_address, :locality,
                  :region, :postal_code, :country_id, :email,
                  :contact_form_url, :contact_type_id,
                  contact_numbers_attributes: %i[id label number _destroy])
  end
end
