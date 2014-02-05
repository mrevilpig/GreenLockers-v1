json.status true
json.updates @accesses do |a|
  json.pin a.pin
  json.barcode a.barcode
  json.box_id a.box.name
end