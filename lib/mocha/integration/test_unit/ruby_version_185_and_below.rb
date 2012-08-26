require 'test/unit/testcase'
require 'mocha/integration/test_unit/assertion_counter'
require 'mocha/integration/monkey_patcher'
require 'mocha/expectation_error'

module Mocha

  module Integration

    module TestUnit

      module RubyVersion185AndBelow
        def self.description
          "monkey patch for standard library in Ruby <= v1.8.5"
        end
        def self.included(mod)
          MonkeyPatcher.apply(mod, RunMethodPatch)
        end
        module RunMethodPatch
          def run(result)
            assertion_counter = AssertionCounter.new(result)
            yield(Test::Unit::TestCase::STARTED, name)
            @_result = result
            begin
              begin
                setup
                __send__(@method_name)
                mocha_verify(assertion_counter)
              rescue Mocha::ExpectationError => e
                add_failure(e.message, e.backtrace)
              rescue Test::Unit::AssertionFailedError => e
                add_failure(e.message, e.backtrace)
              rescue StandardError, ScriptError
                add_error($!)
              ensure
                begin
                  teardown
                rescue Mocha::ExpectationError => e
                  add_failure(e.message, e.backtrace)
                rescue Test::Unit::AssertionFailedError => e
                  add_failure(e.message, e.backtrace)
                rescue StandardError, ScriptError
                  add_error($!)
                end
              end
            ensure
              mocha_teardown
            end
            result.add_run
            yield(Test::Unit::TestCase::FINISHED, name)
          end
        end
      end

    end

  end

end
