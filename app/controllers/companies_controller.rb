class CompaniesController < ApplicationController
  before_action :set_company, only: %i[ show edit update destroy]

  # GET /companies or /companies.json
  def index
    if params['screen']
      case params['screen']
      when "Great Companies"
        @companies = Company.where("great = true").order("symbol")
      when "Big 5"
        @companies = Company.where("roic_avg10 > 10 and equity_avg_growth10 > 10 and free_cash_flow_avg_growth10 > 10 and eps_avg_growth10 > 10 and revenue_avg_growth10 > 10").order("symbol")
      when "Big 5 Intrinsic Value Discounted"
        # @companies = Company.where("roic_avg10 > 10 and equity_avg_growth10 > 10 and free_cash_flow_avg_growth10 > 10 and eps_avg_growth10 > 10 and revenue_avg_growth10 > 10 and price <= intrinsic_value").sort_by {|c| c.price / c.intrinsic_value}
        @companies = Company.where("roic_avg10 > 10 and equity_avg_growth10 > 10 and free_cash_flow_avg_growth10 > 10 and eps_avg_growth10 > 10 and revenue_avg_growth10 > 10 and price <= intrinsic_value").order("symbol")
      when "Intrinsic Value Discounted"
        # @companies = Company.where('price > 0 and price < intrinsic_value').sort_by {|c| c.price / c.intrinsic_value}
        @companies = Company.where('price > 0 and price < intrinsic_value').order("symbol")
      # else
      #   @companies = Company.all
      end
    else
      @companies = Company.all
    end
    # @companies = Company.where("roic_avg10 > 10 and equity_avg_growth10 > 10 and free_cash_flow_avg_growth10 > 10 and eps_avg_growth10 > 10 and revenue_avg_growth10 > 10")
    # @companies = Company.where("price < intrinsic_value and price < graham_number")
    # @companies = Company.where("price < intrinsic_value")
    # @companies = Company.where("price < graham_number")
  end
  
  # GET /companies/1 or /companies/1.json
  def show
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies or /companies.json
  def create
    @company = Company.new(company_params)

    respond_to do |format|
      if @company.pull and @company.save
        format.html { redirect_to @company, notice: "Company was successfully created." }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def addUSCompanies
    AddUsCompaniesJob.perform_later
    respond_to do |format|
      format.html { redirect_to companies_url, notice: "Adding companies..." }
      format.json { head :no_content }
    end
  end

  def updateAllCompanies
    UpdateAllCompaniesJob.perform_later(params['company_ids'])
    respond_to do |format|
      num_companies = "all"
      if params['company_ids']
        num_companies = params['company_ids'].length
      end
      format.html { redirect_back fallback_location: root_path, notice: "Pulling financials for #{num_companies} companies." }
      format.json { head :no_content }
    end
  end

  # PATCH/PUT /companies/1 or /companies/1.json
  def update
    respond_to do |format|
      if params['company']['pullFinancials']
        @company.pull
      end

      if @company.update(company_params)
        if params['company']['recalculate']
          @company.calculate
        end
        format.html { redirect_to @company, notice: "Company was successfully updated." }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1 or /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url, notice: "Company was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def company_params
      params.require(:company).permit(:symbol, :eps_override, :eps_growth_rate_override, :future_pe_override, :great)
    end
    
end
