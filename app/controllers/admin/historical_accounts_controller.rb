class Admin::HistoricalAccountsController < Admin::BaseController
  before_action :load_person
  before_action :load_historical_account, only: %i[edit update confirm_destroy destroy]
  layout :get_layout

  def index
    @historical_accounts = @person.historical_accounts.includes(roles: :translations)
    render_design_system(:index, :legacy_index, next_release: false)
  end

  def new
    @historical_account = @person.historical_accounts.build
    render_design_system(:new, :legacy_new, next_release: false)
  end

  def create
    @historical_account = @person.historical_accounts.build(historical_account_params)
    if @historical_account.save
      redirect_to admin_person_historical_accounts_url(@person), notice: "Historical account created"
    else
      render_design_system(:new, :legacy_new, next_release: false)
    end
  end

  def edit
    render_design_system(:edit, :legacy_edit, next_release: false)
  end

  def update
    if @historical_account.update(historical_account_params)
      redirect_to admin_person_historical_accounts_url(@person), notice: "Historical account updated"
    else
      render_design_system(:edit, :legacy_edit, next_release: false)
    end
  end

  def confirm_destroy
    @roles = @historical_account.roles.collect(&:name).to_sentence
  end

  def destroy
    @historical_account.destroy!
    redirect_to admin_person_historical_accounts_url(@person), notice: "Historical account deleted"
  end

private

  def get_layout
    if preview_design_system?(next_release: false)
      "design_system"
    else
      "admin"
    end
  end

  def load_person
    @person = Person.friendly.find(params[:person_id])
  end

  def load_historical_account
    @historical_account = @person.historical_accounts.find(params[:id])
  end

  def historical_account_params
    params.require(:historical_account).permit(
      :summary,
      :body,
      :born,
      :died,
      :major_acts,
      :interesting_facts,
      role_ids: [],
      political_party_ids: [],
    )
  end
end
