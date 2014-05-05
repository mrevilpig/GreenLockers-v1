require "net/http"
require "uri"

class Locker < ActiveRecord::Base
  belongs_to :branch
  has_many :boxes
  has_many :packages, :through => :boxes
  has_many :privileges
  has_many :devicelog
  
  # Create associated boxes after creating the locker
  def init_locker
    box_params = {}
    box_params[:locker_id] = self.id
    30.times do |i|
      box_params[:name] = (i+1).to_s
      box_params[:size] = 1;
      box_params[:status] = 0;
      b = Box.new(box_params)
      if b.save
        b.init_box
      end
    end
    # 8.times do |i|
      # box_params[:name] = 'B'+(i+1).to_s
      # box_params[:size] = 2;
      # box_params[:status] = 0;
      # b = Box.new(box_params)
      # if b.save
        # b.init_box
      # end
    # end
    # 6.times do |i|
      # box_params[:name] = 'C'+(i+1).to_s
      # box_params[:size] = 3;
      # box_params[:status] = 0;
      # b = Box.new(box_params)
      # if b.save
        # b.init_box
      # end
    # end
  end
  
  def enforce_sync
    uri = URI.parse("http://echo.jsontest.com/status/true")

    http = Net::HTTP.new(uri.host, uri.port)
    #request = Net::HTTP::Get.new(uri.request_uri)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"device_id" => self.name.to_s})
    #request.basic_auth("username", "password")
    response = http.request(request)
    if response.body
      body = JSON.parse response.body
      if body["status"] == 'true'
        return true
      end
    end
    return false
  end
  
end
