
  json.status true
  json.branches @branches do |b|
    json.branch_name b.name
    json.addr b.st_address
  end
