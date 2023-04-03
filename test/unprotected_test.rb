require 'test_helper'

class UnprotectedTest < ActiveSupport::TestCase
  setup do
    @console = SupervisedTestConsole.new(user: 'jorge', reason: 'Some very good reason')
    @user = users(:julia)
    @user_2 = users(:jorge)
    execute_decrypt_and_enter_reason
  end

  teardown do
    @console.stop
  end

  test 'can modify encrypted attributes in unprotected mode' do
    @console.execute <<~RUBY
      user = User.find(#{@user.id})
      user.name = 'othername'
      puts user.save!
    RUBY

    assert_includes @console.output, 'true'
  end

  test 'can modify encrypted attributes in unprotected mode (lockbox attribute save)' do
    @console.execute <<~RUBY
      user = User.find(#{@user.id})
      user.color = 'green'
      puts user.save!
    RUBY

    assert_includes @console.output, 'true'
  end

  test 'can modify encrypted attributes in unprotected mode (update and check after)' do
    @console.execute <<~RUBY
      user = User.find(#{@user.id})
      puts user.update(name: 'othername', color: 'green')
    RUBY
    assert_includes @console.output, 'true'
    assert_equal @user.reload.name, 'othername'
    assert_equal @user.reload.color, 'green'
  end

  test 'can check attributes in unprotected mode (dirty check)' do
    @console.execute <<~RUBY
      user = User.find(#{@user.id})
      user.name = 'othername'
      user.color = 'green'
      puts user.changes
    RUBY

    assert_includes @console.output, 'othername'
    assert_includes @console.output, 'green'
  end

  test 'can modify encrypted attributes in unprotected mode (update_column)' do
    @console.execute <<~RUBY
      user = User.find(#{@user.id})
      puts user.update_column(:name, 'othername')
    RUBY
    assert_includes @console.output, 'true'
    assert_equal @user.reload.name, 'othername'
  end

  test 'can modify encrypted attributes in protected mode (update_columns)' do
    @console.execute <<~RUBY
      user = User.find(#{@user.id})
      puts user.update_columns({name: 'othername', color: 'orange'})
    RUBY
    assert_includes @console.output, 'true'

    assert_equal @user.reload.name, 'othername'
    assert_equal @user.reload.color, 'orange'
  end

  test 'create a new entity while in unprotected mode' do
    @console.execute <<~RUBY
      User.create! name: 'test', color: 'purple', email: 'other@email.com'
    RUBY

    assert_equal User.last.email, 'other@email.com'
    assert_equal User.last.color, 'purple'
  end

  test 'destroy an entities while in protected mode' do
    total_users = User.all.count

    @console.execute <<~RUBY
      User.first.destroy
    RUBY

    assert_equal User.all.count, total_users - 1
  end

  test 'destroy all entities while in protected mode' do
    @console.execute <<~RUBY
      User.destroy_all
    RUBY

    assert_equal User.all.count, 0
  end

  test 'pluck_test (name, color)' do
    @console.execute <<~RUBY
      User.first.update!(color: 'red')
      User.second.update!(color: 'blue')
      puts User.pluck(:color, :name)
    RUBY

    assert_includes @console.output, 'jorge', 'julia'
    assert_includes @console.output, 'red', 'blue'
    refute_includes @console.output, User.first.color_ciphertext
  end

  private

  def execute_decrypt_and_enter_reason
    type_when_prompted 'I need to fix encoding issue with Message 123456' do
      @console.execute 'decrypt!'
    end
  end
end
