class Employee < ActiveRecord::Base
  has_many :packages
  has_many :loggings
  has_many :permissions
  has_many :privileges
  has_many :device_logs
  CONSTANT = YAML.load_file("#{Rails.root}/config/constant.yml")
  
  def name
    if (self.first_name and self.first_name)
      return self.first_name + ' ' + self.last_name
    elsif self.first_name
      return self.first_name
    elsif self.last_name
      return self.last_name
    else
      return 'noname'
    end
  end
  
  def push_operator_info locker_name, box_names
    uri = URI.parse(CONSTANT['PROXY_SERVER_BASE_URL_1'])
    #uri = URI.parse('http://echo.jsontest.com/status/true')

    http = Net::HTTP.new(uri.host, uri.port)
    #request = Net::HTTP::Get.new(uri.request_uri)
    request = Net::HTTP::Post.new(uri.request_uri)
    operator_info_list = {"box_id" => box_names, "staff_id" => self.id.to_s, "password" => self.password}
    request.set_form_data({"action" => "PushOperatorInfo", "sDeviceID" => locker_name, "OperatorInfoList" => [operator_info_list].to_json, "uMillsec" => '6000' })
    #request.basic_auth("username", "password")
    logger.info 'push'
    logger.info locker_name 
    logger.info box_names
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
  
  def remove_operator_info locker_name
    uri = URI.parse(CONSTANT['PROXY_SERVER_BASE_URL_1'])
    #uri = URI.parse('http://echo.jsontest.com/status/true')

    http = Net::HTTP.new(uri.host, uri.port)
    #request = Net::HTTP::Get.new(uri.request_uri)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"action" => "RemoveOperatorInfo", "sDeviceID" => locker_name, "staffIDs" => [self.id.to_s].to_json, "uMillsec" => '6000' })
    #request.basic_auth("username", "password")
    response = http.request(request)
    logger.info 'remove'
    logger.info locker_name 
    if response.body
      body = JSON.parse response.body
      logger.info body
      if body["status"]
        return true
      end
    end
    return false
  end
  
  def push_admin_info locker_name
    uri = URI.parse(CONSTANT['PROXY_SERVER_BASE_URL_1'])
    #uri = URI.parse('http://echo.jsontest.com/status/true')

    http = Net::HTTP.new(uri.host, uri.port)
    #request = Net::HTTP::Get.new(uri.request_uri)
    request = Net::HTTP::Post.new(uri.request_uri)
    admin_info_list = { "staff_id" => self.id.to_s, "password" => self.password}
    
    request.set_form_data({"action" => "PushAdminInfo", "sDeviceID" => locker_name, 'AdminInfoList' => [admin_info_list].to_json, "uMillsec" => '6000'})
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
  
  def remove_admin_info locker_name
    uri = URI.parse(CONSTANT['PROXY_SERVER_BASE_URL_1'])
    #uri = URI.parse('http://echo.jsontest.com/status/true')
    
    http = Net::HTTP.new(uri.host, uri.port)
    #request = Net::HTTP::Get.new(uri.request_uri)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"action" => "RemoveAdminInfo", "sDeviceID" => locker_name, "staffIDs" => [self.id.to_s].to_json, "uMillsec" => '6000' })
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
  
  def check_role role_string
    r = self.role
    if (CONSTANT[role_string] & r) != 0
      return true
    end
    return false
  end
  
  def print_role
    r = self.role
    roles = ''
    return roles if r.nil?
    if ( CONSTANT['EMPLOYEE_ROLE_OPERATOR'] & r) != 0
      roles += "Operator" 
    end
    if ( CONSTANT['EMPLOYEE_ROLE_DEVICE_ADMIN'] & r) != 0
      if roles != ""
        roles += " | "
      end
      roles += "Admin" 
    end
    return roles
  end
  
end
