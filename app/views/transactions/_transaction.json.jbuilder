json.extract! transaction, :id, :company_id, :account_id, :number_of_shares, :price, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
