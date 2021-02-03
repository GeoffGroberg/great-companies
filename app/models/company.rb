class Company < ApplicationRecord
  validates :symbol, uniqueness: true

  def pull
    # use an external api to pull company info
    url = "https://fmpcloud.io/api/v3/profile/#{self.symbol}?apikey=#{$apiKey}"
    body = apiCall(url)
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
  end
  
  def pullProfile
  end
  
  def pullAnnualStatements
  end
  
  private
  
  def apiCall(url)
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
