json.extract! company, :id, :symbol, :name, :created_at, :updated_at
json.url company_url(company, format: :json)
