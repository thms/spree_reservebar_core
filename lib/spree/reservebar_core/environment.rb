module Spree
  module ReservebarCore
    class Environment
      include Core::EnvironmentExtension

      attr_accessor :rules, :actions
    end
  end
end
