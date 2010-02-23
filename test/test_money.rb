require File.join(File.dirname(__FILE__), 'helper')

class TestMoney < Test::Unit::TestCase
  context 'BigMoney' do
    setup do
      Object.send(:remove_const, :Cake) if defined?(Cake)
      class ::Cake
        include DataMapper::Resource
        property :id,   Serial
        property :type, String
        money    :price, :default => BigMoney.new(0, :aud)
      end # Cake
    end

    should 'behave like accessor' do
      price = BigMoney.new('2.50', :aud)
      cake  = Cake.create(:type => 'carrot')

      assert cake.price = price
      assert_equal price, cake.price
    end

    should 'be accepted by constructor' do
      price = BigMoney.new('2.80', :aud)
      assert_nothing_raised do
        cake = Cake.create(:type => 'sponge', :price => price)
        assert_equal price, cake.price
      end
    end

    should 'have BigMoney default' do
      price = BigMoney.new(0, :aud)
      cake  = Cake.create(:type => 'banana')
      assert_equal price, cake.price
    end
  end
end # TestMoney
