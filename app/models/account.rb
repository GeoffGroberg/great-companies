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
    self.companies.each do |c|
      shares = 0
      c.transactions.each do |t|
        shares += t.number_of_shares
      end
      unless active_companies.include? c
        if shares > 0
          active_companies << c
        elsif shares == 0
          inactive_companies << c
        end
      end
      
      self.gain_amount = 0.0
      self.cost = 0.0
      self.market_value = 0.0
      self.companies.each do |company|
        company.account_process(self)
        self.gain_amount += company.gain_amount
        self.cost += company.cost
        self.market_value += company.market_value
      end
      self.gain_percent = self.gain_amount / self.cost * 100
    end
  end
  
end

