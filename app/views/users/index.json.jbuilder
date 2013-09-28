json.array!(@users) do |user|
  json.extract! user, :first_name, :last_name, :middle_name, :home_phone, :mobile_phone, :email, :st_address, :apt_address, :city, :state_id, :zip, :preferred_branch_id, :user_name
  json.url user_url(user, format: :json)
end
