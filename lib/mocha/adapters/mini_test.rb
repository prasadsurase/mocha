require 'mocha_standalone'
require 'mocha/expectation_error'

module Mocha
  module Adapters
    module MiniTest

      class AssertionCounter
        def initialize(test_case)
          @test_case = test_case
        end

        def increment
          @test_case.assert(true)
        end
      end

      include Mocha::API

      def self.description
        "adapter for MiniTest gem >= v3.3.0"
      end

      def self.included(mod)
        Mocha::ExpectationErrorFactory.exception_class = ::MiniTest::Assertion
      end

      def before_setup
        mocha_setup
        super
      end

      def before_teardown
        return unless passed?
        assertion_counter = AssertionCounter.new(self)
        mocha_verify(assertion_counter)
      ensure
        super
      end

      def after_teardown
        super
        mocha_teardown
      end
    end
  end
end

