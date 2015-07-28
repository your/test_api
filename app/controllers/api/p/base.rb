module API
  module P
    class Base < Grape::API
      mount API::P::Users
    end
  end
end