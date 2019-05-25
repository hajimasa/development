class HomeController < ApplicationController

  require 'net/http'

  def top

    today = Date.today.strftime("%Y%m%d")
    tommorow = (Date.today + 1).strftime("%Y%m%d")

    @connpass_results = get_connpass_events_data(today)
    @atnd_results = get_atnd_events_data(today)
    @doorkeeper_results = get_doorkeeper_events_data(tommorow)

  end

  def get_atnd_events_data(date)
    query = URI.encode_www_form({ ymd: "#{date}" })
    uri = URI.parse("http://api.atnd.org/events/?format=json&#{query}")
    atnd_response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.open_timeout = 5
      http.read_timeout = 10
      http.get(uri.request_uri)
    end
    @atnd_results = JSON.parse(atnd_response.body)
    @atnd_results = @atnd_results["events"]
  end

  def get_connpass_events_data(date)
    query = URI.encode_www_form({ ymd: "#{date}" })
    uri = URI.parse("https://connpass.com/api/v1/event/?#{query}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    http.use_ssl = true
    connpass_response = http.request(request)
    @connpass_results = JSON.parse(connpass_response.body)
    @connpass_results = @connpass_results["events"]
  end

  def get_doorkeeper_events_data(date)
    query = URI.encode_www_form({ until: "#{date}" })
    uri = URI.parse("https://api.doorkeeper.jp/events?#{query}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    http.use_ssl = true
    doorkeeper_response = http.request(request)
    @doorkeeper_results = JSON.parse(doorkeeper_response.body)
  end

end
