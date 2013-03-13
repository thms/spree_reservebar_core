module Spree
  module Admin
    class TestController < BaseController
      
      def test
        sleep(3)
        render :json => {"Status" => "OK"}
      end
    end
  end
end