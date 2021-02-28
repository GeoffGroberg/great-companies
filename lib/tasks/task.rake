namespace :task do
  desc "update companies, or other tasks"

  task etfs: :environment do
    companies = Company.where(is_etf: true)
    companies.each do |c|
      puts c.symbol
    end
    puts "#{companies.length} etfs"
  end

  task inactives: :environment do
    companies = Company.where(is_actively_trading: false)
    companies.each do |c|
      puts c.symbol
    end
    puts "#{companies.length} inactive companies"
  end

end