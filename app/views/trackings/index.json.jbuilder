json.array!(@trackings) do |tracking|
  json.extract! tracking, :package_id, :employee_id, :time, :type, :branch_id
  json.url tracking_url(tracking, format: :json)
end
