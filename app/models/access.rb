require 'digest/sha1'

class Access < ActiveRecord::Base
  belongs_to :box
  CONSTANT = YAML.load_file("#{Rails.root}/config/constant.yml")
  
  def generate_pin
    rand = Random.new
    pin = rand.rand(999999).to_s 
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
    self.update_request_id = self.box.locker.access_request_id + 1
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
    barcode = self.barcode.nil? ? nil : self.barcode
    pin = self.pin.nil? ? nil : self.pin
    access_info_list = {"box_id" => self.box.name.to_s, "pin" => pin, "barcode" => barcode}
    params = {"action" => "PushAccessInfo", "sDeviceID" => self.box.locker.name.to_s, 'AccessInfoList' => [access_info_list].to_json, 'uMillsec' => '6000' }
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
