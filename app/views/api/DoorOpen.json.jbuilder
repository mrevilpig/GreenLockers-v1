json.array!(@box) do |b|
  json.extract! b, :name, :locker, :branch
end
