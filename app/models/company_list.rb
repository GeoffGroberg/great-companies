class CompanyList < ApplicationRecord
  belongs_to :company
  belongs_to :list
  acts_as_list scope: :list
  # acts_as_list scope: [:list_id, :company_id]
end
