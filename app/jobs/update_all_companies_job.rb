class UpdateAllCompaniesJob < ApplicationJob
  # include SuckerPunch::Job
  # workers 2
  queue_as :default

  def perform(company_ids = nil)
    # update companies with current info
    if company_ids.present?
      companies = Company.where(id: company_ids)
    else
      companies = Company.all
    end
    puts "Updating #{companies.count} companies..."
    companies.each do |company|
      puts company.name
      company.pull
    end
  end

end
