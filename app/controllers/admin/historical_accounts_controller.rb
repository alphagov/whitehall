class Admin::HistoricalAccountsController < Admin::BaseController
  before_filter :load_person
  before_filter :load_historical_account, only: [:edit, :update, :destroy]


  def index
    @historical_accounts = @person.historical_accounts.includes(:roles)
  end

  def new
    @historical_account = @person.historical_accounts.build
  end

  def create
    @historical_account = @person.historical_accounts.build(params[:historical_account])
    if @historical_account.save
      redirect_to admin_person_historical_accounts_url(@person), notice: 'Historical account created'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @historical_account.update_attributes(params[:historical_account])
      redirect_to admin_person_historical_accounts_url(@person), notice: 'Historical account updated'
    else
      render :edit
    end
  end

  def destroy
    @historical_account.destroy
    redirect_to admin_person_historical_accounts_url(@person), notice: 'Historical account deleted'
  end

  private

  def load_person
    @person = Person.find(params[:person_id])
  end

  def load_historical_account
    @historical_account = @person.historical_accounts.find(params[:id])
  end
end
