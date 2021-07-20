class Account < ApplicationRecord
  has_many :transactions
  
  def companies
    # companies in this account with transactions
    companies = []
    self.transactions.each do |t|
      unless companies.include? t.company
        companies << t.company
      end
    end
    companies
  end
  
  # active positions for an account
  def active_companies
    # companies with more than 0 shares currently
    active_companies = []
    self.companies.each do |c|
      shares = 0
      c.transactions.each do |t|
        shares += t.number_of_shares
      end
      unless active_companies.include? c
        # active_companies << c
        if shares > 0
          active_companies << c
        end
      end
    end
    active_companies
  end

  # old positions in an account (owned shares at one time but not anymore)
  def inactive_companies
    # companies with 0 shares currently
    inactive_companies = []
    self.companies.each do |c|
      shares = 0
      c.transactions.each do |t|
        shares += t.number_of_shares
      end
      unless inactive_companies.include? c
        # active_companies << c
        if shares == 0
          inactive_companies << c
        end
      end
    end
    inactive_companies
  end

  def gain
    total_gain_amount = 0.0
    total_cost = 0.0
    self.companies.each do |c|
      gain_percent, gain_amount, cost = c.gain(self)
      total_gain_amount += gain_amount
      total_cost += cost
    end
    total_gain_percent = total_gain_amount / total_cost * 100
    return total_gain_percent, total_gain_amount, total_cost
  end
  
end

