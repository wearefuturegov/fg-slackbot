require 'cowsay'

Handler = Proc.new do |req, res|
  res.status = 200
  res['Content-Type'] = 'text/plain'
  res.body = "Hey bud"
end