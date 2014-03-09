json.array!(@products) do |product|
  json.extract! product, :title, :description, :price
  json.url product_url(product, format: :json)
end