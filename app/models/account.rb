class Account < ApplicationRecord
  has_many :transactions
  attr_accessor :companies, :active_companies, :inactive_companies, :gain_percent, :gain_amount, :market_value, :cost
  
  def calculate_companies
    # calculate info about the companies in this account
    self.companies = []
    self.transactions.each do |t|
      unless companies.include? t.company
        self.companies << t.company
      end
    end

    self.active_companies = []
    self.inactive_companies = []
    self.gain_amount = 0.0
    self.cost = 0.0
    self.market_value = 0.0

    self.companies.each do |company|
      company.account_process(self)
      if company.account_shares > 0
        self.active_companies << company
      else
        self.inactive_companies << company
      end
      self.gain_amount += company.account_gain_amount
      self.cost += company.account_cost
      self.market_value += company.account_market_value
    end
    self.gain_percent = self.gain_amount / self.cost * 100

  end
  
end

