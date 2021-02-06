class KeyMetric < ApplicationRecord
  belongs_to :company
  validates :company, uniqueness: {scope: :date}
end
