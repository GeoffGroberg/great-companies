class ApplicationController < ActionController::Base
  $apiKey = Rails.application.credentials.fmpcloudApiKey
end
