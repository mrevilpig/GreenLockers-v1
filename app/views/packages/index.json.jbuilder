json.array!(@packages) do |package|
  json.extract! package, :user_id, :locker_id, :size
  json.url package_url(package, format: :json)
end
