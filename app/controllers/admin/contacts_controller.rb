class Admin::ContactsController < Admin::BaseController
  respond_to :html

  before_filter :find_contactable, only: [:new, :create]
  before_filter :find_contact, only: [:edit, :update]

  def index
  end

  def new
    @contact = @contactable.contacts.build
  end

  def edit
  end

  def update
    @contact.update_attributes(params[:contact])
    if @contact.save
      redirect_to([:admin, @contact.contactable])
    else
      render :edit
    end
  end

  def create
    @contact = @contactable.contacts.build(params[:contact])
    if @contact.save
      redirect_to([:admin, @contact.contactable])
    else
      render :edit
    end
  end

private
  def find_contactable
    @contactable = case params[:contactable_type]
    when "Organisation"
      Organisation.find(params[:contactable_id])
    when "WorldwideOffice"
      WorldwideOffice.find(params[:contactable_id])
    else
      raise ActiveRecord::NotFound
    end
  end

  def find_contact
    @contact = Contact.find(params[:id])
    @contactable = @contact.contactable
  end
end
