class CompaniesController < ApplicationController
  before_action :set_company, only: %i[ show edit update destroy]

  # GET /companies or /companies.json
  def index
    if params['screen']
      case params['screen']

      when "Great Companies"
        @companies = Company.where("great = true").order("sector, industry")

      when "Big 5"
        @companies = Company.where("roic_avg10 > 10 and equity_avg_growth10 > 10 and free_cash_flow_avg_growth10 > 10 and eps_avg_growth10 > 10 and revenue_avg_growth10 > 10").order("sector, industry")

      when "Big 5 Intrinsic Value Discounted"
        # @companies = Company.where("roic_avg10 > 10 and equity_avg_growth10 > 10 and free_cash_flow_avg_growth10 > 10 and eps_avg_growth10 > 10 and revenue_avg_growth10 > 10 and price <= intrinsic_value").sort_by {|c| c.price / c.intrinsic_value}
        # @companies = Company.where("roic_avg10 > 10 and equity_avg_growth10 > 10 and free_cash_flow_avg_growth10 > 10 and eps_avg_growth10 > 10 and revenue_avg_growth10 > 10 and price <= intrinsic_value").order("sector, industry")
        @companies = Company.where("roic_avg10 > 0 and equity_avg_growth10 > 0 and free_cash_flow_avg_growth10 > 0 and eps_avg_growth10 > 0 and revenue_avg_growth10 > 0 and roic_avg5 > 0 and equity_avg_growth5 > 0 and free_cash_flow_avg_growth5 > 0 and eps_avg_growth5 > 0 and revenue_avg_growth5 > 0 and roic_avg3 > 0 and equity_avg_growth3 > 0 and free_cash_flow_avg_growth3 > 0 and eps_avg_growth3 > 0 and revenue_avg_growth3 > 0 and price <= intrinsic_value and country != 'CN'").order("sector, industry")

      when "Big 5, 5 Year, Discounted"
        @companies = Company.where("ipoDate > '2011-01-01' and roic_avg5 > 0 and equity_avg_growth5 > 0 and free_cash_flow_avg_growth5 > 0 and eps_avg_growth5 > 0 and revenue_avg_growth5 > 0 and roic_avg3 > 0 and equity_avg_growth3 > 0 and free_cash_flow_avg_growth3 > 0 and eps_avg_growth3 > 0 and revenue_avg_growth3 > 0 and price <= intrinsic_value and country != 'CN'").order("sector, industry")

      when "Intrinsic Value Discounted"
        # @companies = Company.where('price > 0 and price < intrinsic_value').sort_by {|c| c.price / c.intrinsic_value}
        @companies = Company.where('price > 0 and price < intrinsic_value').order("sector, industry")

      when "Magic Sort"
        num_companies = 3000
        # get the largest n companies
        # sorted = Company.where('roic_avg5 > 0 and pe > 0 and description not like ?', "%china%").order('mktCap DESC').limit(num_companies)
        sorted = Company.where('roic_avg3 > 0 and pe > 0 and (country = "US" or country = "CA") and intrinsic_value > price').order('mktCap DESC').limit(num_companies)
        # sorted = Company.where('roic_avg10 > 0 and pe > 0').order('mktCap DESC').limit(num_companies)
        
        # sort by roic in reverse
        # puts "sort by roic in reverse"
        sorted = sorted.sort_by {|c| c.roic_avg3}.reverse
        r = 0
        sorted.each do |c|
          r += 1
          c.magic_sort = r
          # puts "r: #{r} magic_sort: #{c.magic_sort} pe: #{c.pe} roic_avg5: #{c.roic_avg5} symbol: #{c.symbol}"
        end

        # sort by pe
        # puts "sort by pe"
        sorted = sorted.sort_by {|c| c.pe}
        r = 0
        sorted.each do |c|
          r += 1
          c.magic_sort += r
          # puts "r: #{r} magic_sort: #{c.magic_sort} pe: #{c.pe} roic_avg5: #{c.roic_avg5} symbol: #{c.symbol}"
        end

        # sort by magic_sort
        # puts "sort by magic_sort"
        sorted = sorted.sort_by {|c| c.magic_sort}
        sorted.each do |c|
          # puts "r: #{r} magic_sort: #{c.magic_sort} pe: #{c.pe} roic_avg5: #{c.roic_avg5} symbol: #{c.symbol}"
        end
        
        @companies = sorted

      when "Growing Averages"
        @companies = Company.where('roic_avg3 > roic_avg5 and roic_avg5 > roic_avg10 and intrinsic_value > price and country = "US"')

      when "Over 15"
        @companies = Company.where('roic_avg3 > 14 and roic_avg5 > 14 and roic_avg10 > 14 and equity_avg_growth3 > 14 and free_cash_flow_avg_growth3 > 14 and eps_avg_growth3 > 14 and revenue_avg_growth3 > 14 and intrinsic_value > price and (country = "US" or country = "CA")')


      end
    else
      @companies = Company.all
    end
    # update quotes?
    if params['updateQuotes'] == 'true'
      Company::pullQuotes(@companies)
      flash.now[:notice] = "Updated quotes at #{Time.now.strftime('%l:%M:%S %P')}."
    end
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
    @company = Company.find_or_create_by(symbol: company_params['symbol'].upcase)

    respond_to do |format|
      if @company
        if @company.pull
          format.html { redirect_to @company, notice: "Company was updated." }
          format.json { render :show, status: "Company was updated.", location: @company }
        else
          format.html { redirect_to @company, alert: "Unable to pull info." }
          format.json { render :show, alert: "Unable to pull info.", location: @company }
        end
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

  def updateCompanies
    UpdateCompaniesJob.perform_later(params['company_ids'])
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
        result = @company.update(company_params) and @company.pull
      elsif params['company']['recalculate']
        result = @company.update(company_params) and @company.calculate
      else
        result = @company.update(company_params)
      end
      if result
        format.html { redirect_to @company, notice: "Company was successfully updated." }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { redirect_to @company, alert: "Company was unable to be updated." }
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
