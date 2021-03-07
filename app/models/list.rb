class List < ApplicationRecord
  has_many :company_lists, -> { order 'position' }
  has_many :companies, through: :company_lists
end
