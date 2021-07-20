class Company < ApplicationRecord
  validates :symbol, uniqueness: true
  has_many :key_metrics
  has_many :notes
  has_many :transactions
  has_many :company_lists, -> { order 'position' }
  has_many :lists, through: :company_lists
  # acts_as_list :scope => :list
  attr_accessor :magic_sort
  
  def gain(account = nil)
    if !account
      return nil
    end
    unless account.transactions.present?
      return nil
    end
    cost = 0.0
    balance = 0.0
    shares = 0
    account.transactions.each do |t|
      if t.company == self
        if t.number_of_shares > 0
          cost += t.number_of_shares * t.price
        end
        balance -= t.number_of_shares * t.price
        shares += t.number_of_shares
      end
    end
    balance += (shares * self.price)
    gain_percent = balance / cost * 100
    gain_amount = balance
    return gain_percent, gain_amount, cost
  end
  
  def pull(force: false)
    self.pullQuote
    financials_result = self.pullKeyMetrics(force: force)
    insider_trading_result = self.pullInsiderTrading()
    calculate_result = self.calculate # calculate growth rates from key metrics
    if financials_result
      return true
    else
      puts "*** Unable to pull financials."
      return false
    end
  end
  
  def calculate
    # run calculations on key metrics
    # yearly growth
    key_metrics = self.key_metrics.where(quarterly: false).order("date DESC")
    key_metrics.each_with_index do |v, k|
      if key_metrics.size > k + 1
        prev = key_metrics[k + 1]

        key_metrics[k].equity_growth = percent_change(v.equity, prev.equity)

        key_metrics[k].eps_growth = percent_change(v.eps, prev.eps)
        
        key_metrics[k].revenue_growth = percent_change(v.revenue, prev.revenue)
        
        key_metrics[k].free_cash_flow_growth = percent_change(v.free_cash_flow, prev.free_cash_flow)

        key_metrics[k].save
      end
    end

    # yearly averages
    self.dividend_yield_avg = avg('dividend_yield', 5, drop_hi = true)
    self.roic_avg10 = avg('roic', 10, drop_hi = true, drop_low = true)
    self.roic_avg5 = avg('roic', 5)
    self.roic_avg3 = avg('roic', 3)
    self.equity_avg_growth10 = avg('equity_growth', 10, drop_hi = true, drop_low = true)
    self.equity_avg_growth5 = avg('equity_growth', 5)
    self.equity_avg_growth3 = avg('equity_growth', 3)
    self.free_cash_flow_avg_growth10 = avg('free_cash_flow_growth', 10, drop_hi = true, drop_low = true)
    self.free_cash_flow_avg_growth5 = avg('free_cash_flow_growth', 5)
    self.free_cash_flow_avg_growth3 = avg('free_cash_flow_growth', 3)
    self.eps_avg_growth10 = avg('eps_growth', 10, drop_hi = true, drop_low = true)
    self.eps_avg_growth5 = avg('eps_growth', 5)
    self.eps_avg_growth3 = avg('eps_growth', 3)
    self.revenue_avg_growth10 = avg('revenue_growth', 10, drop_hi = true, drop_low = true)
    self.revenue_avg_growth5 = avg('revenue_growth', 5)
    self.revenue_avg_growth3 = avg('revenue_growth', 3)

    # debt ratio
    if key_metrics and key_metrics[0]
      self.debt_ratio = key_metrics[0].debt_ratio
    end

    # graham number
    if key_metrics and key_metrics[1]
      self.graham_number = key_metrics[1].graham_number
    end

    # eps growth rate estimate, based on avg equity growth
    if self.equity_avg_growth10
      eps_growth_rate = self.equity_avg_growth10
    elsif self.equity_avg_growth5
      eps_growth_rate = self.equity_avg_growth5
    elsif self.equity_avg_growth3
      eps_growth_rate = self.equity_avg_growth3
    else
      eps_growth_rate = nil
    end
    # allow eps_growth_rate_override
    if self.eps_growth_rate_override
      eps_growth_rate = self.eps_growth_rate_override
    end
    self.eps_growth_rate = eps_growth_rate
    
    # default PE
    self.default_pe = self.eps_growth_rate

    # avg historical PE
    # (averaged for a minimum of 2 years but up to 10 years)
    if key_metrics.length >= 2
      avg_pe = 0.0
      y = 0
      key_metrics.each do |m|
        if m['pe_ratio']
          y += 1
          avg_pe += m['pe_ratio']
        end
        break if y >= 10
      end
      avg_pe = avg_pe / y
    else
      avg_pe = nil
    end
    self.avg_pe = avg_pe
    
    # future PE
    if self.default_pe.nil? and self.avg_pe.nil?
      future_pe = nil
    elsif self.default_pe.nil? or self.default_pe < 0
      future_pe = self.avg_pe * 2
    elsif self.avg_pe.nil? or self.avg_pe < 0
      future_pe = self.default_pe * 2
    else
      future_pe = [self.default_pe, self.avg_pe].min * 2
    end
    # allow future_pe_override
    if self.future_pe_override
      future_pe = self.future_pe_override
    end
    self.future_pe = future_pe
    
    # future EPS
    if self.eps.nil? or self.eps_growth_rate.nil?
      future_eps = nil
    else
      # allow eps_override
      future_eps = self.eps_override || self.eps

      r = self.eps_growth_rate / 100 # convert percent to decimal
      y = 0
      while y < 10
        y += 1
        future_eps = future_eps * (1 + r)
      end
    end
    self.future_eps = future_eps
    
    # future price
    if self.future_eps.nil? or self.future_pe.nil?
      future_price = nil
    else
      future_price = self.future_eps * self.future_pe
    end
    self.future_price = future_price
    
    # intrinsic value
    self.intrinsic_value = self.intrinsicValue
    
    return self.save
  end

  def intrinsicValue
    # discount the future price by 15% for 10 years
    unless self.future_price
      return nil
    end
    intrinsicValue = self.future_price
    r = 0.15
    y = 0
    while y < 10
      y += 1
      intrinsicValue = intrinsicValue * (1 - r)
    end
    # if intrinsicValue.infinite? or intrinsicValue.to_f.nan?
    #   return nil
    # end
    intrinsicValue
  end

  def discount
    if self.intrinsic_value and self.price
      # discount = (1 - (self.price / self.intrinsic_value)) * 100
      discount = ((self.intrinsic_value - self.price) / self.intrinsic_value) * 100
      # if discount < -9000
      #   discount = nil
      # end
    else
      return nil
    end
    # if discount.to_f.nan?
    #   return nil
    # end
    if self.intrinsic_value < 0
      discount = discount.abs() * -1
    end
    discount
  end
  
  def dcf_discount
    if self.dcf and self.price
      discount = ((self.dcf - self.price) / self.dcf) * 100
    else
      discount = nil
    end
    discount
  end
  
  def pullProfile
    body = Company::apiCall(request: 'profile', symbols: self.symbol)
    unless body
      self.errors.add(:base, "Unable to pull company profile. No body.")
      return false
    end
    c = body.first
    if c.nil?
      self.errors.add(:base, "Unable to pull company profile. No data.")
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
    self.dcf = c['dcf']
    self.mktCap = c['mktCap']
    self.volAvg = c['volAvg']
    self.industry = c['industry']
    self.sector = c['sector']
    self.exchangeShortName = c['exchangeShortName']
    self.country = c['country']
    self.ipoDate = c['ipoDate']
    self.is_actively_trading = c['isActivelyTrading']
    self.is_etf = c['isEtf']
    self.website = c['website']
    self.save
    return true
  end
  
  def pullQuote
    Company::pullQuotes([self])
  end
  
  def self.pullQuotes(companies)
    # we do these in batches of 100 or less
    batch_size = 100
    # symbols should be a comma separated list of stock symbols (or 1 symbol)
    symbols = ''
    x = 0
    companies.each do |c|
      x += 1
      unless x == 1
        symbols << ','
      end
      symbols << c.symbol
      if x == batch_size
        result = Company::pullQuoteBatch(symbols)
        # reset for the next batch
        x = 0
        symbols = ''
      end
    end
    # we need to pullQuoteBatch if we didn't reach batch_size
    if x > 0
      result = Company::pullQuoteBatch(symbols)
    end
    result
  end

  def self.pullQuoteBatch(symbols)
    body = Company::apiCall(request: 'quote', symbols: symbols)
    unless body.present?
      puts "ERROR: Unable to pull company quote(s). No body."
      return false
    end
    # make the API call and update companies
    body.each do |quote|
      company = Company.find_by(symbol: quote['symbol'])
      company.price = quote['price'].to_f
      company.pe = quote['pe'].to_f
      company.eps = quote['eps'].to_f
      if quote['earningsAnnouncement'].present?
        company.earnings_announcement = quote['earningsAnnouncement'].to_datetime
      end
      company.save
    end
    return true
  end
    
  def pullKeyMetrics(limit: 20, force: false)
    # is it time to pull anew?
    pull = true
    # if we already pulled after the earnings_announcment time, then no need to pull again
    if self.financials_pulled_at.present? and self.earnings_announcement.present? and self.financials_pulled_at >= self.earnings_announcement
      pull = false
    end
    # if there's a future earnings announcement, and the last time we pulled was less than 3 months from that time, then no need to pull again
    if self.earnings_announcement.present? and DateTime.now < self.earnings_announcement and self.financials_pulled_at.present? and self.financials_pulled_at >= self.earnings_announcement.prev_month(3)
      pull = false
    end
    if force
      pull = true
    end
    unless pull
      return true # no need to pull financials right now
    end

    # update the company profile
    profile_result = self.pullProfile
    unless profile_result
      puts "*** Unable to pull profile."
      return false
    end
    
    # get annual key metrics
    key_metrics = Company::apiCall(request: 'key-metrics', symbols: self.symbol, limit: limit)
    unless key_metrics and key_metrics.first
      puts "*** Unable to pull annual key metrics."
      return false
    end
    # create a new KeyMetric for each year
    x = 0
    while x < limit
      x += 1
      if key_metrics[x-1] and key_metrics[x-1]['date']
        statement_date = key_metrics[x-1]['date']
        key_metric = KeyMetric.find_or_create_by(date: statement_date, company_id: self.id, quarterly: false)
        key_metric.roic = key_metrics[x-1]['roic'].to_f * 100
        key_metric.equity = key_metrics[x-1]['shareholdersEquityPerShare'].to_f
        key_metric.eps = key_metrics[x-1]['netIncomePerShare'].to_f
        key_metric.revenue = key_metrics[x-1]['revenuePerShare'].to_f
        key_metric.free_cash_flow = key_metrics[x-1]['freeCashFlowPerShare'].to_f
        longTermDebt = key_metrics[x-1]['interestDebtPerShare'].to_f
        key_metric.debt_ratio = longTermDebt / key_metric.free_cash_flow
        key_metric.graham_number = key_metrics[x-1]['grahamNumber'].to_f
        key_metric.pe_ratio = key_metrics[x-1]['peRatio'].to_f
        key_metric.dividend_yield = key_metrics[x-1]['dividendYield'].to_f * 100
        key_metric.save
      end
    end
    # update the quarterly key metrics
    key_metrics_q = Company::apiCall(request: 'key-metrics', symbols: self.symbol, period: 'quarter', limit: 4)
    unless key_metrics_q and key_metrics_q.length >= 4
      puts "*** Unable to pull quarterly key metrics."
      return false
    end
    # delete the existing quarterlies
    KeyMetric.where(company_id: self.id, quarterly: true).destroy_all
    key_metrics_q.each do |key_metric_q|
      key_metric = KeyMetric.find_or_create_by(company_id: self.id, quarterly: true, date: key_metric_q['date'])
      key_metric.roic = key_metric_q['roic'].to_f * 100
      key_metric.equity = key_metric_q['shareholdersEquityPerShare'].to_f
      key_metric.eps = key_metric_q['netIncomePerShare'].to_f
      key_metric.revenue = key_metric_q['revenuePerShare'].to_f
      key_metric.free_cash_flow = key_metric_q['freeCashFlowPerShare'].to_f
      longTermDebt = key_metric_q['interestDebtPerShare'].to_f
      key_metric.debt_ratio = longTermDebt / key_metric.free_cash_flow / 4
      key_metric.graham_number = key_metric_q['grahamNumber'].to_f
      key_metric.pe_ratio = key_metric_q['peRatio'].to_f
      key_metric.save
    end

    self.financials_pulled_at = DateTime.now
    return true
  end
    
  def pullInsiderTrading
    url = "https://fmpcloud.io/api/v4/insider-trading/?symbol=#{self.symbol}&apikey=#{Rails.application.credentials.fmpcloudApiKey}&limit=100"
    begin
      puts "*** Starting API CALL: #{url}"
      response = HTTParty.get(url, { timeout: 5 })
      puts "*** Finished"
    rescue
      puts "*** ERROR: failed api call: #{url}"
      return false
    end
    # puts response.body, response.code, response.message, response.headers.inspect
    unless response.code == 200
      self.errors.add(:base, "*** Unsuccessful API call. Response code: #{response.code}")
      return false
    end
    body = JSON.parse(response.body)

    unless body
      self.errors.add(:base, "Unable to pull insider-trading. No body.")
      return false
    end
    t = body.first
    if t.nil?
      self.errors.add(:base, "Unable to pull insider-trading. No data.")
      return false
    end
    # add up acquisition and dispositions
    a = 0
    d = 0
    body.each do |t|
      if t['acquistionOrDisposition'] == 'A'
        a += t['securitiesTransacted'].to_f
      elsif t['acquistionOrDisposition'] == 'D'
        d += t['securitiesTransacted'].to_f
      end
    end
    puts("*** INSIDER TRADING for #{self.symbol} (Acquisitions vs Dispositions)")
    puts("a: #{a}     d: #{d}")
    insider_trading = ((a - d) / (a + 0.001)) * 100
    self.insider_trading = insider_trading
    self.save
    self.insider_trading
  end
  
  private
  
  def percent_change(new_num, old_num)
    new_num = new_num.to_f
    old_num = old_num.to_f
    percent_change = (old_num - new_num) / old_num.abs() * -100
    percent_change
  end

  def avg(varName, periods, drop_hi = false, drop_low = false)
    # calculate yearly averages
    key_metrics = self.key_metrics.where(quarterly: false).order("date DESC")
    unless key_metrics.first
      return nil
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
      # don't include nil or infinite metrics
      unless metric[varName].nil? or metric[varName].infinite?
        metrics << metric[varName]
      end
    end
    if drop_hi
      metrics.delete(metrics.max)
    end
    if drop_low
      metrics.delete(metrics.min)
    end
    # if periods >= 10 # for periods >= 10, drop hi and low
    #   metrics.delete(metrics.max)
    #   metrics.delete(metrics.min)
    # # elsif periods >= 5 # for periods >= 5, drop hi
    # # # else # drop hi
    # #   metrics.delete(metrics.max)
    # end
    if metrics.length == 0
      return nil
    end
    avg = metrics.sum / metrics.length
    avg
  end
  
  def self.apiCall(request:, symbols:, period: 'year', limit: 20)
    url = "https://fmpcloud.io/api/v3/#{request}/#{symbols}?apikey=#{Rails.application.credentials.fmpcloudApiKey}&limit=#{limit}&period=#{period}"
    begin
      puts "*** Starting API CALL: #{url}"
      response = HTTParty.get(url, { timeout: 5 })
      puts "*** Finished"
    rescue
      puts "*** ERROR: failed api call: #{url}"
      return false
    end
    # puts response.body, response.code, response.message, response.headers.inspect
    unless response.code == 200
      self.errors.add(:base, "*** Unsuccessful API call. Response code: #{response.code}")
      return false
    end
    body = JSON.parse(response.body)
    body
  end

end
