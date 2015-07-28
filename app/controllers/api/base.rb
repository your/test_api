module API
  class Base < Grape::API
    mount API::P::Base
  end
end