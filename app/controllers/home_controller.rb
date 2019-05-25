class HomeController < ApplicationController

  require 'net/http'

  def top

    today = Date.today.strftime("%Y%m%d")
    tommorow = (Date.today + 1).strftime("%Y%m%d")

    @connpass_results = get_connpass_events_data(today)
    @atnd_results = get_atnd_events_data(today)
    @doorkeeper_results = get_doorkeeper_events_data(tommorow)

    @results = {}
    @distance_list = []

    @connpass_results.each_with_index do |result, i|
      id = "c#{i}"
      distance = distance(35.68123, 139.767125, result["lat"], result["lon"]).round(2)
      @results["#{id}"] = [ result["event_url"], result["title"], result["started_at"] ]
      @distance_list <<[id, distance]
    end

    @atnd_results.each_with_index do |result, i|
      id = "a#{i}"
      distance = distance(35.68123, 139.767125, result["event"]["lat"], result["event"]["lon"]).round(2)
      @results["#{id}"] = [ result["event"]["event_url"], result["event"]["title"], result["event"]["started_at"] ]
      @distance_list <<[id, distance]
    end

    @distance_list = @distance_list.sort_by(&:last).take(10)

  end

  def get_atnd_events_data(date)
    query = URI.encode_www_form({ ymd: "#{date}" })
    uri = URI.parse("http://api.atnd.org/events/?format=json&#{query}")
    atnd_response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.open_timeout = 5
      http.read_timeout = 10
      http.get(uri.request_uri)
    end
    atnd_results = JSON.parse(atnd_response.body)
    atnd_results["events"]
  end

  def get_connpass_events_data(date)
    query = URI.encode_www_form({ ymd: "#{date}" })
    uri = URI.parse("https://connpass.com/api/v1/event/?#{query}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    http.use_ssl = true
    connpass_response = http.request(request)
    connpass_results = JSON.parse(connpass_response.body)
    connpass_results["events"]
  end

  def get_doorkeeper_events_data(date)
    query = URI.encode_www_form({ until: "#{date}" })
    uri = URI.parse("https://api.doorkeeper.jp/events?#{query}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    http.use_ssl = true
    doorkeeper_response = http.request(request)
    JSON.parse(doorkeeper_response.body)
  end

  def distance(lat1, lng1, lat2, lng2)
    # ラジアン単位に変換
    x1 = lat1.to_f * Math::PI / 180
    y1 = lng1.to_f * Math::PI / 180
    x2 = lat2.to_f * Math::PI / 180
    y2 = lng2.to_f * Math::PI / 180

    # 地球の半径 (km)
    radius = 6378.137

    # 差の絶対値
    diff_y = (y1 - y2).abs

    calc1 = Math.cos(x2) * Math.sin(diff_y)
    calc2 = Math.cos(x1) * Math.sin(x2) - Math.sin(x1) * Math.cos(x2) * Math.cos(diff_y)

    # 分子
    numerator = Math.sqrt(calc1 ** 2 + calc2 ** 2)

    # 分母
    denominator = Math.sin(x1) * Math.sin(x2) + Math.cos(x1) * Math.cos(x2) * Math.cos(diff_y)

    # 弧度
    degree = Math.atan2(numerator, denominator)

    # 大円距離 (km)
    degree * radius
  end

end
