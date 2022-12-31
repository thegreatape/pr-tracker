def table_contents(table)
  headers = table.find_all("thead th").map {|t| t.text}

  table.find_all("tbody tr").map do |row|
    headers.zip(row.find_all('td').map(&:text)).to_h
  end
end
