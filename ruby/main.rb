require "./cotoha"

c = Cotoha.new("clientId", "clientSecret")
result = c.similarity("test", "test")

if result.has_key?("err") then
    p result["err"]
else
    p result
end

