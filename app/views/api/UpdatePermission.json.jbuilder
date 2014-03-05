json.status true
json.updates @permissions do |employee, permission|
  json.staff_id employee
  json.box_ids do
  	json.array! permission.collect{|p| p.box_id}
  end
end