require 'digest/sha1'

class Access < ActiveRecord::Base
  belongs_to :box
  CONSTANT = YAML.load_file("#{Rails.root}/config/constant.yml")
  
  def generate_pin
    rand = Random.new
    pin = (rand.rand(899999)+100000).to_s 
    self.barcode = nil
    logger.info "Pin:" + pin.to_s # for debugging
    self.pin = Digest::SHA1.hexdigest pin
    #self.update_request_id = self.box.locker.access_request_id + 1
    if self.save
      self.push_access_info
      return pin
    end
    return nil
  end
  
  def save_barcode barcode
    self.barcode = barcode
    self.pin = nil
    #self.update_request_id = self.box.locker.access_request_id + 1
    logger.info self.barcode 
    if self.save
      self.push_access_info
      return true
    end
    return false
  end
  
  def clear
    self.barcode = nil
    self.pin = nil
    #self.update_request_id = self.box.locker.access_request_id + 1
    if self.save
      self.push_access_info
      return true
    end
    return false
  end
  
  def push_access_info
    uri = URI.parse(CONSTANT['PROXY_SERVER_BASE_URL_1'])
    #uri = URI.parse('http://echo.jsontest.com/status/true')
    
    http = Net::HTTP.new(uri.host, uri.port)
    #request = Net::HTTP::Get.new(uri.request_uri)
    request = Net::HTTP::Post.new(uri.request_uri)
    access_info_list = []
    boxes = self.box.locker.boxes
    boxes.each do |b|
      a = b.access
      if a.barcode.nil? == false or a.pin.nil? == false
        obj = {"box_id" => b.name.to_s, "pin" => a.pin, "barcode" => a.barcode}
        access_info_list.push obj
      end
    end
    params = {"action" => "PushAccessInfo", "sDeviceID" => self.box.locker.name.to_s, 'AccessInfoList' => access_info_list.to_json, 'uMillsec' => '6000' }
    logger.info params
    request.set_form_data(params)
    #request.basic_auth("username", "password")
    response = http.request(request)
    if response.body
      body = JSON.parse response.body
      logger.info body
      if body["status"]
        return true
      end
    end
    return false
  end
end
