class UpdateCompaniesJob < ApplicationJob
  # include SuckerPunch::Job
  # workers 2
  queue_as :default

  def perform(company_ids = nil)
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    job_errors = []
    # update companies with current info
    if company_ids.present?
      companies = Company.where(id: company_ids)
    else
      companies = Company.all
    end
    puts "Updating #{companies.count} companies..."
    x = 0
    companies.each do |company|
      x += 1
      puts "Pulling update for company #{x}, #{company.symbol}"
      begin
        company.pull
      rescue
        job_errors << "Unable to pull update for #{company.symbol}."
      end
      # break if x > 10
    end
    if job_errors.present?
      puts "****************"
      puts "****************"
      puts "****************"
      job_errors.each do |e|
        puts e
      end
      puts "ERROR: Couldn't pull info for #{job_errors.length} companies (above)."
      puts "****************"
      puts "****************"
      puts "****************"
    end

    end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    ellapsed_time = end_time - start_time
    puts "****************"
    puts "Job time: #{ellapsed_time.round(2)} seconds (#{(ellapsed_time / 60).round(2)} minutes)."
    puts "****************"
  end

end
