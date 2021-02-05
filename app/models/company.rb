class Company < ApplicationRecord
  validates :symbol, uniqueness: true
  has_many :annual_key_financials

  def pull
    profile_result = self.pullProfile
    financials_result = self.pullAnnualKeyFinancials
    if profile_result and financials_result
      return true
    end
  end
  
  def pullProfile
    body = apiCall(request: 'profile')
    c = body.first
    if c.nil?
      self.errors.add(:base, "Unable to pull company info. No data.")
      return false
    end
    # convert nil values to ''
    c.each do |k,v|
      if v.nil?
        c[k] = ''
      end
    end
    self.symbol = c['symbol']
    self.name = c['companyName']
    self.description = c['description']
    self.price = c['price']
    self.dcf = c['dcf']
    self.mktCap = c['mktCap']
    self.volAvg = c[':volAvg']
    self.industry = c[':industry']
    self.sector = c['sector']
    self.exchangeShortName = c['exchangeShortName']
    self.country = c['country']
    self.ipoDate = c['ipoDate']
    self.save
    return true
  end
  
  def pullAnnualKeyFinancials(limit: 20)
    # get financial statements
    key_metrics_statements = apiCall(request: 'key-metrics', limit: limit)
    balance_sheet_statements = apiCall(request: 'balance-sheet-statement')
    income_statements = apiCall(request: 'income-statement')
    cash_flow_statements = apiCall(request: 'cash-flow-statement')
    # create a new AnnualKeyFinancial for each year
    x = 0
    while x < 20
      x += 1
      if key_metrics_statements[x-1] and key_metrics_statements[x-1]['date']
        statement_date = key_metrics_statements[x-1]['date']
        annual_key_financial = AnnualKeyFinancial.find_or_create_by(date: statement_date, company_id: self.id)
        annual_key_financial.roic = key_metrics_statements[x-1]['roic'].to_f * 100
        annual_key_financial.equity = balance_sheet_statements[x-1]['totalStockholdersEquity'].to_f
        annual_key_financial.eps = income_statements[x-1]['eps'].to_f
        annual_key_financial.revenue = income_statements[x-1]['revenue'].to_f
        annual_key_financial.free_cash_flow = cash_flow_statements[x-1]['freeCashFlow'].to_f
        longTermDebt = balance_sheet_statements[x-1]['longTermDebt'].to_f
        annual_key_financial.debt_ratio = longTermDebt / annual_key_financial.free_cash_flow
        annual_key_financial.save
      end
    end
    return true
  end
  
  private
  
  def apiCall(request:, period: 'year', limit: 20)
    url = "https://fmpcloud.io/api/v3/#{request}/#{self.symbol}?apikey=#{$apiKey}&limit=#{limit}&period=#{period}"
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    unless response.code == '200'
      self.errors.add(:base, "Unsuccessful API call. Response code: #{response.code}")
      return false
    end
    body = JSON.parse(response.body)
    body
  end

end
