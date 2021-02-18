class Company < ApplicationRecord
  validates :symbol, uniqueness: true
  has_many :key_metrics

  def pull
    profile_result = self.pullProfile
    financials_result = self.pullKeyMetrics
    self.calculate # calculate growth rates from key metrics
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
        key_metric.graham_number = key_metrics[x-1]['grahamNumber'].to_f
        key_metric.pe_ratio = key_metrics[x-1]['peRatio'].to_f
        key_metric.save
      end
    end
    # update the ttm keyMetric
    # IMPORTANT: there should only ever be 1 key metric where ttm = true for a given company
    if key_metrics_ttm and key_metrics_ttm.first
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
      key_metric_ttm.graham_number = key_metrics_ttm['grahamNumberTTM'].to_f
      key_metric_ttm.pe_ratio = key_metrics_ttm['peRatioTTM'].to_f
      key_metric_ttm.save
    end
    return true
  end
    
  def calculate
    # run calculations on key metrics
    # yearly growth
    key_metrics = self.key_metrics.order("date DESC")
    key_metrics.each_with_index do |v, k|
      if key_metrics.size > k + 1
        prev = key_metrics[k + 1]
        key_metrics[k].equity_growth = ((v.equity / prev.equity) - 1) * 100
        key_metrics[k].eps_growth = ((v.eps / prev.eps) - 1) * 100
        key_metrics[k].revenue_growth = ((v.revenue / prev.revenue) - 1) * 100
        key_metrics[k].free_cash_flow_growth = ((v.free_cash_flow / prev.free_cash_flow) - 1) * 100
        key_metrics[k].save
      end
    end
    # yearly averages
    self.roic_avg10 = avg('roic', 10)
    self.roic_avg5 = avg('roic', 5)
    self.roic_avg2 = avg('roic', 3)
    self.equity_avg_growth10 = avg('equity_growth', 10)
    self.equity_avg_growth5 = avg('equity_growth', 5)
    self.equity_avg_growth2 = avg('equity_growth', 3)
    self.free_cash_flow_avg_growth10 = avg('free_cash_flow_growth', 10)
    self.free_cash_flow_avg_growth5 = avg('free_cash_flow_growth', 5)
    self.free_cash_flow_avg_growth2 = avg('free_cash_flow_growth', 3)
    self.eps_avg_growth10 = avg('eps_growth', 10)
    self.eps_avg_growth5 = avg('eps_growth', 5)
    self.eps_avg_growth2 = avg('eps_growth', 3)
    self.revenue_avg_growth10 = avg('revenue_growth', 10)
    self.revenue_avg_growth5 = avg('revenue_growth', 5)
    self.revenue_avg_growth2 = avg('revenue_growth', 3)
    # debt ratio
    if key_metrics and key_metrics[1]
      self.debt_ratio = key_metrics[1].debt_ratio
    end
    # graham number
    if key_metrics and key_metrics[1]
      self.graham_number = key_metrics[1].graham_number
    end
    # intrinsic value
    self.intrinsic_value = self.intrinsicValue
    # pe ratio
    if key_metrics and key_metrics.first
      self.pe_ratio = key_metrics.first.pe_ratio
    end
    
    self.save
  end

  def intrinsicValue
    futureGrowthRate = self.futureGrowthRate
    unless futureGrowthRate
      return nil
    end
    puts "---"
    puts "futureGrowthRate: #{futureGrowthRate}"
    # calculate future free cash flow
    y = 0

    key_metrics = self.key_metrics.order("date DESC")
    unless key_metrics.first
      return nil
    end
    # drop ttm metrics - only use annual reports
    if key_metrics.first.ttm
      key_metrics = key_metrics.drop(1)
    end

    freeCashFlow = key_metrics[1]['free_cash_flow'].to_f
    puts "---"
    puts "freeCashFlow: #{freeCashFlow}"
    futureFCF = []
    r = futureGrowthRate
    while y < 10
      y += 1
      freeCashFlow = freeCashFlow * (1+r)
      futureFCF << freeCashFlow
    end
    futureFCF << futureFCF.last * 10
    
    # discount the future FCF by 15%
    dFCFs = []
    r = 0.15
    y = 0
    futureFCF.each do |freeCashFlow|
      y += 1
      dFCF = futureFCF[y-1] / ((1 + r)**y)
      dFCFs << dFCF
    end
    dFCFs.pop # drop the last item
    dFCFs << dFCFs.last * 10
    dFCFs.each do |test|
      puts "---"
      puts "dFCF: #{test}"
    end
    intrinsicValue = dFCFs.last
    intrinsicValue
  end
  
  def futureGrowthRate
    # if self.roic_avg10 and self.equity_avg_growth10 and self.free_cash_flow_avg_growth10 and self.eps_avg_growth10 and self.revenue_avg_growth10
    #   futureGrowthRate = self.roic_avg10 + self.equity_avg_growth10 + self.free_cash_flow_avg_growth10 + self.eps_avg_growth10 + self.revenue_avg_growth10
    # elsif self.roic_avg5 and self.equity_avg_growth5 and self.free_cash_flow_avg_growth5 and self.eps_avg_growth5 and self.revenue_avg_growth5
    #   futureGrowthRate = self.roic_avg5 + self.equity_avg_growth5 + self.free_cash_flow_avg_growth5 + self.eps_avg_growth5 + self.revenue_avg_growth5
    # else
    #   return nil
    # end
    # futureGrowthRate = futureGrowthRate / 5
    # futureGrowthRate = futureGrowthRate / 100 # convert into decimal instead of percent
    # futureGrowthRate
    
    growthRates = []
    if self.roic_avg10
      growthRates << self.roic_avg10
    end
    if self.roic_avg5
      growthRates << self.roic_avg5
    end
    if self.roic_avg2
      growthRates << self.roic_avg2
    else
      return nil
    end
    futureGrowthRate = growthRates.min / 100
    if futureGrowthRate <= -1.0
      futureGrowthRate = -1.0
    end
    futureGrowthRate
  end
  
  def discount
    if self.intrinsic_value and self.price
      discount = (1 - (self.price / self.intrinsic_value)) * 100
      if discount < -900
        discount = nil
      end
    else
      discount = nil
    end
    discount
  end
  
  
  private
  
  def avg(varName, periods)
    # calculate yearly averages
    key_metrics = self.key_metrics.order("date DESC")
    unless key_metrics.first
      return nil
    end
    # drop ttm metrics for periods > 3
    if periods > 3 and key_metrics.first.ttm
      key_metrics = key_metrics.drop(1)
    end
    # make sure there is enough data to calculate over n periods
    if key_metrics.size < periods
      return nil
    end
    metrics = []
    n = 0
    key_metrics.each do |metric|
      n += 1
      break if n > periods
      unless metric[varName].nil?
        metrics << metric[varName]
      end
    end
    if periods >= 10 # for periods >= 10, drop hi and low
      metrics.delete(metrics.max)
      metrics.delete(metrics.min)
    elsif periods >= 5 # for periods >= 5, drop hi
    # else # drop hi
      metrics.delete(metrics.max)
    end
    if metrics.length == 0
      return nil
    end
    avg = metrics.sum / metrics.length
    avg
  end
  
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
