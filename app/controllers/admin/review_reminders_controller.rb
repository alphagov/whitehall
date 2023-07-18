class Admin::ReviewRemindersController < Admin::BaseController
  before_action :load_document
  before_action :load_review_reminder, only: %i[edit update]
  before_action :build_review_reminder, only: %i[new create]
  before_action :enforce_permissions!
  layout "design_system"

  def new; end

  def create
    if @review_reminder.update(review_reminder_params)
      redirect_to admin_edition_path(@document.latest_edition), notice: "Review date created"
    else
      render :new
    end
  end

  def edit; end

  def update
    if @review_reminder.update(review_reminder_params)
      redirect_to admin_edition_path(@document.latest_edition), notice: "Review date updated"
    else
      render :edit
    end
  end

private

  def load_document
    @document = Document.friendly.find(params[:document_id])
  end

  def load_review_reminder
    @review_reminder = @document.review_reminder
  end

  def build_review_reminder
    @review_reminder = @document.build_review_reminder
  end

  def enforce_permissions!
    enforce_permission!(:update, @document.latest_edition)
  end

  def review_reminder_params
    params
      .require(:review_reminder)
      .permit(:id, :email_address, :review_at)
      .merge(creator_id: current_user.id)
  end
end
