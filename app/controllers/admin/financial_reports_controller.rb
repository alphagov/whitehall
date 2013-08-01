class Admin::FinancialReportsController < Admin::BaseController
  before_filter :load_organisation
  before_filter :load_financial_report, only: [:edit, :update, :destroy]
  
  def index
  end

  def edit

  end
  
  def new
    @financial_report = @organisation.financial_reports.build({year: Time.zone.now.year})
  end
  def create
    @financial_report = @organisation.financial_reports.build(params[:financial_report])
    if @financial_report.save
      redirect_to [:admin, @organisation, FinancialReport],
      notice: "Created Financial Report"
    else
      render :new, status: :bad_request
    end
  end

  def update
    if @financial_report.update_attributes(params[:financial_report])
      redirect_to [:admin, @organisation, FinancialReport],
      notice: "Updated Financial Report"
    else
      render :edit, status: :bad_request
    end
  end


  def destroy
    @financial_report.destroy
    redirect_to admin_organisation_financial_reports_path(@organisation), notice: "Deleted Successfully"
  end

  def load_financial_report
    @financial_report ||= @organisation.financial_reports.find(params[:id])
  end
  def load_organisation
    @organisation ||= Organisation.find(params[:organisation_id])
  end
end
