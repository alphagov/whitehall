class Admin::ContactsController < Admin::BaseController
  before_filter :find_contactable
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
      redirect_to [:admin, @contact.contactable, Contact]
    else
      render :edit
    end
  end

  def create
    @contact = @contactable.contacts.build(params[:contact])
    if @contact.save
      redirect_to [:admin, @contact.contactable, Contact]
    else
      render :edit
    end
  end

  def destroy
    if @contact.destroy
      redirect_to [:admin, @contact.contactable, Contact]
    else
      render :edit
    end
  end

  private

  def find_contactable
    @contactable  = case params.keys.grep(/(.+)_id$/).first.to_sym
    when :organisation_id
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
end
