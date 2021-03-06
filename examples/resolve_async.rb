# Example that resolves three hostnames in an aynchronous fashion.
#
# Outputs:
#   Got result for www.google.com!
#   Got result for github.com!
#   Got result for www.yahoo.com!
#   all done!
# 
require 'unbound'

ctx = Unbound::Context.new
resolver = Unbound::Resolver.new(ctx)

at_exit do
  resolver.close unless resolver.closed?
end

# Add some callbacks to the resolver
resolver.on_answer do |q, result|
  puts "Got result for #{q.name} : rcode: #{result[:rcode]}!"
end
resolver.on_cancel do |q|
  puts "Query canceled: #{q.name}!"
end
resolver.on_error do |q, error_code|
  puts "Query had error: #{q.name} #{error_code}!"
end

names = ["www.google.com", "www.yahoo.com", "github.com", "notadomain"]
names.each do |name|
  query = Unbound::Query.new(name, 1, 1)
  query.on_answer do |query, result|
    puts "query-level callback for on_answer: #{name}"
  end
  resolver.send_query(query)
end

io = resolver.io

# Keep looping until we haven't gotten any
while resolver.outstanding_queries? && (::IO.select([io], nil, nil, 5)) 
  ctx.process()
end

resolver.close()
puts "all done!"

