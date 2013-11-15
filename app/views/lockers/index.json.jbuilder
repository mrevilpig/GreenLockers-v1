json.array!(@lockers) do |locker|
  json.extract! locker, :branch_id, :name
  json.url locker_url(locker, format: :json)
end
