class Admin::ContactsController < Admin::BaseController
  include Admin::ContactsHelper

  respond_to :html

  before_filter :find_contactable, only: [:new, :create]
  before_filter :find_contact, only: [:edit, :update, :destroy]
  before_filter :destroy_blank_contact_numbers, only: [:create, :update]

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
      redirect_to(contacts_list_url_for(@contact.contactable))
    else
      render :edit
    end
  end

  def create
    @contact = @contactable.contacts.build(params[:contact])
    if @contact.save
      redirect_to(contacts_list_url_for(@contact.contactable))
    else
      render :edit
    end
  end

  def destroy
    if @contact.destroy
      redirect_to(contacts_list_url_for(@contact.contactable))
    else
      render :edit
    end
  end

private
  def find_contactable
    @contactable = case params[:contactable_type]
    when "Organisation"
      Organisation.find(params[:contactable_id])
    when "WorldwideOrganisation"
      WorldwideOrganisation.find(params[:contactable_id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def find_contact
    @contact = Contact.find(params[:id])
    @contactable = @contact.contactable
  end

  def destroy_blank_contact_numbers
    (params[:contact][:contact_numbers_attributes] || []).each do |index, attributes|
      if attributes.except(:id).values.all?(&:blank?)
        attributes[:_destroy] = "1"
      end
    end
  end

end
