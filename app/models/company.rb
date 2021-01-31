class Company < ApplicationRecord
  validates :symbol, uniqueness: true
end
