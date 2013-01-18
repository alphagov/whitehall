class Admin::ContactsController < Admin::BaseController
  respond_to :html

  def index
  end

  def new
    @contact = @contactable.contacts.build
  end

  def edit
    @contact = Contact.find(params[:id])
  end

  def update
    @contact = Contact.find(params[:id])
    @contact.update_attributes(params[:contact])
    if @contact.save
      redirect_to([:admin, @contact.contactable])
    else
      render :edit
    end
  end
end
