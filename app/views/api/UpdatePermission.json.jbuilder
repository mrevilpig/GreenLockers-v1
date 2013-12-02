json.status true
json.updates @permissions do |employee, permission|
  json.staff_id employee
  json.box_ids do
  	json.array! permission.box_id
  end
end