class Company < ApplicationRecord
  validates :symbol, uniqueness: true
  has_many :key_metrics

  def pull
    profile_result = self.pullProfile
    financials_result = self.pullKeyMetrics
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
  
  def pullKeyMetrics(limit: 20)
    # get financial statements
    key_metrics = apiCall(request: 'key-metrics', limit: limit)
    key_metrics_ttm = apiCall(request: 'key-metrics-ttm', limit: limit)
    # create a new KeyMetric for each year
    x = 0
    while x < limit
      x += 1
      if key_metrics[x-1] and key_metrics[x-1]['date']
        statement_date = key_metrics[x-1]['date']
        key_metric = KeyMetric.find_or_create_by(date: statement_date, company_id: self.id)
        key_metric.roic = key_metrics[x-1]['roic'].to_f * 100
        key_metric.equity = key_metrics[x-1]['shareholdersEquityPerShare'].to_f
        key_metric.eps = key_metrics[x-1]['netIncomePerShare'].to_f
        key_metric.revenue = key_metrics[x-1]['revenuePerShare'].to_f
        key_metric.free_cash_flow = key_metrics[x-1]['freeCashFlowPerShare'].to_f
        longTermDebt = key_metrics[x-1]['interestDebtPerShare'].to_f
        key_metric.debt_ratio = longTermDebt / key_metric.free_cash_flow
        key_metric.save
      end
    end
    # update the ttm keyMetric
    # IMPORTANT: there should only ever be 1 key metric where ttm = true for a given company
    if key_metrics_ttm.first
      key_metrics_ttm = key_metrics_ttm.first
      key_metric_ttm = KeyMetric.find_or_create_by(company_id: self.id, ttm: true)
      key_metric_ttm.date = Date.today.to_s
      key_metric_ttm.roic = key_metrics_ttm['roicTTM'].to_f * 100
      key_metric_ttm.equity = key_metrics_ttm['shareholdersEquityPerShareTTM'].to_f
      key_metric_ttm.eps = key_metrics_ttm['netIncomePerShareTTM'].to_f
      key_metric_ttm.revenue = key_metrics_ttm['revenuePerShareTTM'].to_f
      key_metric_ttm.free_cash_flow = key_metrics_ttm['freeCashFlowPerShareTTM'].to_f
      longTermDebt = key_metrics_ttm['interestDebtPerShareTTM'].to_f
      key_metric_ttm.debt_ratio = longTermDebt / key_metric_ttm.free_cash_flow
      key_metric_ttm.save
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
