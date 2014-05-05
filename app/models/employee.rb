class Employee < ActiveRecord::Base
  has_many :packages
  has_many :loggings
  has_many :permissions
  has_many :privileges
  has_many :device_logs
  
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
    uri = URI.parse("http://echo.jsontest.com/status/true")

    http = Net::HTTP.new(uri.host, uri.port)
    #request = Net::HTTP::Get.new(uri.request_uri)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"device_id" => locker_name, "box_id" => box_names, "staff_id" => self.id.to_s, "password" => self.password})
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
  
  def remove_operator_info locker_name
    uri = URI.parse("http://echo.jsontest.com/status/true")

    http = Net::HTTP.new(uri.host, uri.port)
    #request = Net::HTTP::Get.new(uri.request_uri)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"device_id" => locker_name, "staff_id" => self.id.to_s})
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
  
  def push_admin_info locker_name
    uri = URI.parse("http://echo.jsontest.com/status/true")

    http = Net::HTTP.new(uri.host, uri.port)
    #request = Net::HTTP::Get.new(uri.request_uri)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"device_id" => locker_name, "staff_id" => self.id.to_s, "password" => self.password })
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
  
  def remove_admin_info locker_name
    uri = URI.parse("http://echo.jsontest.com/status/true")

    http = Net::HTTP.new(uri.host, uri.port)
    #request = Net::HTTP::Get.new(uri.request_uri)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"device_id" => locker_name, "staff_id" => self.id.to_s })
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
  
  def check_role role_string
    constant = YAML.load_file("config/constant.yml")
    r = self.role
    if (constant[role_string] & r) != 0
      return true
    end
    return false
  end
  
  def print_role
    constant = YAML.load_file("config/constant.yml")
    r = self.role
    roles = ''
    return roles if r.nil?
    if ( constant['EMPLOYEE_ROLE_OPERATOR'] & r) != 0
      roles += "Operator" 
    end
    if ( constant['EMPLOYEE_ROLE_DEVICE_ADMIN'] & r) != 0
      if roles != ""
        roles += " | "
      end
      roles += "Admin" 
    end
    return roles
  end
  
end
