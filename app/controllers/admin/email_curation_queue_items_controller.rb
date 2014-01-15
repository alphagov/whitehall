class Admin::EmailCurationQueueItemsController < Admin::BaseController
  before_filter :load_email_curation_queue_item, except: [:index]

  def index
    @email_curation_queue_items = EmailCurationQueueItem.order('created_at desc').includes(edition: :document)
  end

  def edit
  end

  def update
    if @email_curation_queue_item.update_attributes(email_curation_queue_item_params)
      redirect_to [:admin, EmailCurationQueueItem], notice: 'Email curation queue item updated.'
    else
      render :edit
    end
  end

  def destroy
    @email_curation_queue_item.destroy
    flash[:notice] = "#{@email_curation_queue_item.title} has been removed from the queue"
    redirect_to [:admin, EmailCurationQueueItem]
  end

  def send_to_subscribers
    Whitehall::GovUkDelivery::GovUkDeliveryEndPoint.notify_from_queue!(@email_curation_queue_item)
    @email_curation_queue_item.destroy
    flash[:notice] = "#{@email_curation_queue_item.title} has been sent to subscribers"
    redirect_to [:admin, EmailCurationQueueItem]
  end

  private
  def load_email_curation_queue_item
    @email_curation_queue_item = EmailCurationQueueItem.find(params[:id])
  end

  def email_curation_queue_item_params
    params.require(:email_curation_queue_item).permit(:title, :summary)
  end
end
