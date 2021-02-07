class UpdateAllCompaniesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # update all companies in our database
    companies = Company.all
    companies.each do |company|
      company.pull
    end
  end

end
