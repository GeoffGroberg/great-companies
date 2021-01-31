class CompaniesController < ApplicationController
  before_action :set_company, only: %i[ show edit update destroy updateFinancials]

  def updateFinancials
    @company = Company.find(params[:id])
    url = "https://fmpcloud.io/api/v3/profile/#{@company.symbol}?apikey=#{$apiKey}"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    response = JSON.parse(response)
    c = response.first
    @company.symbol = c['symbol']
    @company.name = c['companyName']
    @company.price = c['price']
    @company.dcf = c['dcf']
    @company.mktCap = c['mktCap']
    @company.volAvg = c[':volAvg']
    @company.industry = c[':industry']
    @company.sector = c['sector']
    @company.exchangeShortName = c['exchangeShortName']
    @company.country = c['country']
    @company.ipoDate = c['ipoDate']
    if @company.save
      redirect_to @company, notice: "Company was successfully updated."
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  # GET /companies or /companies.json
  def index
    @companies = Company.all
    # @companies.each do |c|
    #   c.destroy
    # end

    # url = "https://fmpcloud.io/api/v3/nasdaq_constituent?apikey=#{$apiKey}"
    # uri = URI(url)
    # response = Net::HTTP.get(uri)
    # response = JSON.parse(response)
    # response.each do |c|
    #   company = Company.new
    #   company.symbol = c['symbol']
    #   company.name = c['name']
    #   company.save
    # end
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
      if @company.save
        format.html { redirect_to @company, notice: "Company was successfully created." }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1 or /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
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
      params.require(:company).permit(:symbol, :name)
    end
end
