json.array!(@branches) do |branch|
  json.extract! branch, :name, :st_address, :apt_address, :city, :state_id, :zip
  json.url branch_url(branch, format: :json)
end
