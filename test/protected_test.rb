require 'test_helper'

class ProtectedTest < ActiveSupport::TestCase
  setup do
    @console = SupervisedTestConsole.new(user: 'jorge', reason: 'Some very good reason')
    @user = users(:julia)
    @user_2 = users(:jorge)
    @user.update_column(:color, 'red')
    @user_2.update_column(:color, 'blue')
    @user = @user.reload
    @user_2 = @user_2.reload
  end

  teardown do
    @console.stop
  end

  test 'show attributes non-encrypted by encrypted' do
    @console.execute <<~RUBY
      puts User.find(#{@user.id}).id
    RUBY
    assert_includes @console.output, @user.id.to_s
  end

  test 'can modify unencrypted attributes in protected mode' do
    assert_nothing_raised do
      @console.execute <<~RUBY
        user = User.find(#{@user.id})
        user.update! email: "other@email.com"
      RUBY
    end
  end

  test "can't modify encrypted attributes in protected mode (attribute save)" do
    assert_raises ActiveRecord::RecordInvalid do
      @console.execute <<~RUBY
        user = User.find(#{@user.id})
        user.name = "othername"
        user.save!
      RUBY
    end
  end

  test "can't modify encrypted attributes in protected mode (lockbox attribute save)" do
    assert_raises Lockbox::Error do
      @console.execute <<~RUBY
        user = User.find(#{@user.id})
        user.color = 'green'
        user.save!
      RUBY
    end
  end

  test "can't modify encrypted attributes in protected mode (save and check after)" do
    @console.execute <<~RUBY
      user = User.find(#{@user.id})
      user.name = "othername"
      puts user.save
    RUBY
    assert_includes @console.output, 'false'
    execute_decrypt_and_enter_reason
    @console.execute <<~RUBY
      user = User.find(#{@user.id})
      puts user.name
    RUBY

    assert_includes @console.output, 'julia'
  end

  test "can't modify encrypted attributes in protected mode (dirty check)" do
    @console.execute <<~RUBY
      user = User.find(#{@user.id})
      user.name = "othertname"
      puts user.changes["name"]
    RUBY
    refute_includes @console.output, 'othername'
  end

  test "can't modify encrypted attributes in protected mode lockbox (dirty check)" do
    @console.execute <<~RUBY
      user = User.find(#{@user.id})
      user.color = "purple"
      puts user.changes["purple"]
    RUBY
    refute_includes @console.output, 'purple'
    refute_includes @console.output, @user.reload.color
  end

  test 'can modify encrypted attributes in protected mode (update_column)' do
    @console.execute <<~RUBY
      user = User.find(#{@user.id})
      puts user.update_column(:name, "othername")
    RUBY
    assert_equal @console.output, 'true'

    execute_decrypt_and_enter_reason
    @console.execute <<~RUBY
      user = User.find(#{@user.id})
      puts user.name
    RUBY

    assert_includes @console.output, 'othername'
  end

  test 'can modify encrypted attributes in protected mode (update_columns)' do
    @console.execute <<~RUBY
      user = User.find(#{@user.id})
      user.update_columns({name: "othername"})
    RUBY
    execute_decrypt_and_enter_reason
    @console.execute <<~RUBY
      user = User.find(#{@user.id})
      puts user.name
    RUBY

    assert_includes @console.output, 'othername'
  end

  test 'create a new entity while in protected mode' do
    assert_raises ActiveRecord::RecordInvalid  do
      @console.execute <<~RUBY
        User.create! name: 'test', email: "other@email.com"
      RUBY
    end
  end

  test 'create a new entity while in protected mode with lockbox' do
    assert_raises Lockbox::Error  do
      @console.execute <<~RUBY
        User.create! name: 'test', color: 'purple', email: "other@email.com"
      RUBY
    end
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

  test 'pluck_test (name)' do
    @console.execute <<~RUBY
      puts User.pluck(:name)
    RUBY

    refute_includes @console.output, 'jorge'
    refute_includes @console.output, 'julia'
  end

  test 'lockbox pluck_test (color)' do
    @console.execute <<~RUBY
      puts User.pluck(:color)
    RUBY

    assert_includes @console.output, User.first.color_ciphertext
    refute_includes @console.output, 'red'
    refute_includes @console.output, 'blue'
  end

  private

  def execute_decrypt_and_enter_reason
    type_when_prompted 'I need to fix encoding issue with Message 123456' do
      @console.execute 'decrypt!'
    end
  end
end
