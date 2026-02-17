class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  throttle("requests/ip", limit: 100, period: 1.minute) do |req|
    req.ip
  end

  throttle("urls/create", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/urls" && req.post?
  end
end