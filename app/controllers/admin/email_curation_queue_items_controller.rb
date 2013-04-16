class Admin::EmailCurationQueueItemsController < Admin::BaseController
  before_filter :load_email_curation_queue_item, except: [:index]

  def index
    @email_curation_queue_items = EmailCurationQueueItem.order('created_at desc').all
  end

  def edit
  end

  def update
    if @email_curation_queue_item.update_attributes(params[:email_curation_queue_item])
      redirect_to [:admin, EmailCurationQueueItem], notice: 'Email curation queue item updated.'
    else
      render :edit
    end
  end

  private
  def load_email_curation_queue_item
    @email_curation_queue_item = EmailCurationQueueItem.find(params[:id])
  end
end
