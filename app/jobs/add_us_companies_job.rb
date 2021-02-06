class AddUsCompaniesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # get a list of companies/stocks that are traded on the NYSE and Nasdaq
    url = "https://fmpcloud.io/api/v3/stock/list?apikey=#{$apiKey}"
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    unless response.code == '200'
      self.errors.add(:base, "Unable to pull the list of stocks. Response code: #{response.code}")
      return false
    end
    body = JSON.parse(response.body)
    c = body.first
    if c.nil?
      self.errors.add(:base, "Unable to pull the list of stocks. No data.")
      return false
    end
    x = 0
    body.each do |c|
      x += 1
      if c['exchange'] =~ /NYSE/i or c['exchange'] =~ /New York/i or c['exchange'] =~ /Nasdaq/i
        # add it if it's not already in our database
        @company = Company.find_by(symbol: c['symbol'])
        unless @company
          # new company (not already in our database)
          @company = Company.new
          @company.symbol = c['symbol']
          @company.pull
        end
      end
      # break if x > 15
    end
  end
end
