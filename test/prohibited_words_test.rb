require 'test_helper'

class ProhibitedWordsTest < ActiveSupport::TestCase
  setup do
    @console = SupervisedTestConsole.new(user: 'jorge', reason: 'Some very good reason')
  end

  teardown do
    @console.stop
  end

  test 'forbids use of Lockbox constantize' do
    command = <<~RUBY
      "Lockbox".constantize
    RUBY
    assert_forbidden_command_attempted(command)
  end

  test 'forbids use of Lockbox.enable_protected_mode' do
    command = <<~RUBY
      Lockbox.enable_protected_mode
    RUBY
    assert_forbidden_command_attempted(command)
  end

  test 'forbids use of Lockbox.disable_protected_mode' do
    command = <<~RUBY
      Lockbox.disable_protected_mode
    RUBY
    assert_forbidden_command_attempted(command)
  end

  private

  def assert_forbidden_command_attempted(command)
    assert_audit_trail commands: [command] do
      assert_difference -> { Console1984::SensitiveAccess.count }, +1 do
        @console.execute command
        puts @console.output
      end
    end

    assert_includes @console.output, "Forbidden command attempted"
    assert Console1984::Command.last.sensitive?
  end

  def assert_command_allowed(command)
    assert_no_difference -> { Console1984::SensitiveAccess.count } do
      @console.execute command
      puts @console.output
    end

    puts @console.output
    assert_not_includes @console.output, "Forbidden command attempted"
    assert_not Console1984::Command.last.sensitive?
  end
end
