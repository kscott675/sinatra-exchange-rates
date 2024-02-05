require "sinatra"
require "sinatra/reloader"
require 'http'
require 'json'

EXCHANGE_API_KEY = ENV['EXCHANGE_API_KEY']
api_url = nil

def fetch_currency_list
  api_url = "http://api.exchangerate.host/list?access_key=#{EXCHANGE_API_KEY}"
  raw_data = HTTP.get(api_url)
  JSON.parse(raw_data.to_s)["currencies"].keys
end

get("/") do
  @symbols = fetch_currency_list
  erb :homepage
end

# Define a route for individual currency conversion
get("/:from_currency") do
  @from_currency = params["from_currency"]
  @symbols = fetch_currency_list
  erb :convert_currency
end

# Define a route for specific currency pair conversion
  get("/:from_currency/:to_currency") do
    @from_currency = params.fetch("from_currency")
    @to_currency = params.fetch("to_currency")
  
    @conversion_url = "http://api.exchangerate.host/convert?access_key=#{EXCHANGE_API_KEY}&from=#{@from_currency}&to=#{@to_currency}&amount=1"
  
    @conversion_data = JSON.parse(HTTP.get(@conversion_url).to_s)
  
    if @conversion_data["success"]
      @conversion_rate = @conversion_data["result"]
      erb :specific_conversion
    else
      @error_message = "Unable to fetch conversion rate."
      erb :error_page
    end
  end
