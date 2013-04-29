class Admin::ContactsController < Admin::BaseController
  before_filter :find_contactable
  before_filter :find_contact, only: [:edit, :update, :destroy, :remove_from_home_page, :add_to_home_page]
  before_filter :destroy_blank_contact_numbers, only: [:create, :update]
  before_filter :extract_show_on_home_page_param, only: [:create, :update]

  def index
  end

  def new
    @contact = @contactable.contacts.build
    @contact.contact_numbers.build
  end

  def edit
    @contact.contact_numbers.build unless @contact.contact_numbers.any?
  end

  def update
    @contact.update_attributes(params[:contact])
    if @contact.save
      handle_show_on_home_page_param
      redirect_to [:admin, @contact.contactable, Contact], notice: %{"#{@contact.title}" updated successfully}
    else
      render :edit
    end
  end

  def create
    @contact = @contactable.contacts.build(params[:contact])
    if @contact.save
      handle_show_on_home_page_param
      redirect_to [:admin, @contact.contactable, Contact], notice: %{"#{@contact.title}" created successfully}
    else
      render :edit
    end
  end

  def destroy
    if @contact.destroy
      redirect_to [:admin, @contact.contactable, Contact], notice: %{"#{@contact.title}" deleted successfully}
    else
      render :edit
    end
  end

  def remove_from_home_page
    @show_on_home_page = '0'
    handle_show_on_home_page_param
    redirect_to [:admin, @contact.contactable, Contact], notice: %{"#{@contact.title}" removed from home page successfully}
  end

  def add_to_home_page
    @show_on_home_page = '1'
    handle_show_on_home_page_param
    redirect_to [:admin, @contact.contactable, Contact], notice: %{"#{@contact.title}" added to home page successfully}
  end

private

  def find_contactable
    @contactable  =
      if params.has_key?(:organisation_id)
        Organisation.find(params[:organisation_id])
      else
        raise ActiveRecord::RecordNotFound
      end
  end

  def find_contact
    @contact = @contactable.contacts.find(params[:id])
  end

  def destroy_blank_contact_numbers
    (params[:contact][:contact_numbers_attributes] || []).each do |index, attributes|
      if attributes.except(:id).values.all?(&:blank?)
        attributes[:_destroy] = "1"
      end
    end
  end

  def extract_show_on_home_page_param
    @show_on_home_page = params[:contact].delete(:show_on_home_page)
  end

  def handle_show_on_home_page_param
    if @contactable.respond_to?(:home_page_contacts) && @show_on_home_page.present?
      if @show_on_home_page == '1'
        @contactable.add_contact_to_home_page!(@contact)
      elsif @show_on_home_page == '0'
        @contactable.remove_contact_from_home_page!(@contact)
      end
    end
  end
end
