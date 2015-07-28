module API
  module P
    class Users < Grape::API
      include API::P::Defaults
      resource :users do
        desc "Return list of users"
        get do
          User.all # obviously you never want to call #all here
        end
      end
    end
  end
end