module API
  module V1
    class Base < Grape::API
      mount API::PRIVATE::Users
    end
  end
end