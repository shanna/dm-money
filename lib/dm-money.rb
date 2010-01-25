require 'big_money'
require 'dm-core'

module DataMapper
  module Money
    def self.included(model)
      model.extend ClassMethods
    end

    module ClassMethods

      # Add a BigMoney property.
      #
      # ==== Parameters
      # name<Symbol>:: Name of the composite money property.
      # options<Hash(Symbol => String)>:: DataMapper property options.
      #
      # ==== Examples
      # class Bike
      #   include DataMapper::Resource
      #   # ... other properties.
      #
      #   money :gst
      #   # public
      #   #   gst #=> BigMoney
      #   #   gst=(value)
      #   #
      #   # property :gst_amount,   BigDecimal, accessor: private
      #   # property :gst_currency, String,     accessor: private, length: 3
      #
      #   money :price, required: true, accessor: protected
      #   # protected
      #   #   price #=> BigMoney
      #   #   price=(value)
      #   #
      #   # property :price_amount,   BigDecimal, accessor: private, required: true
      #   # property :price_currency, String,     accessor: private, required: true, length: 3
      # end
      #--
      # TODO: Validations.
      def money(name, options = {})
        raise ArgumentError.new('You need to pass at least one argument') if name.empty?

        property               = Property.new(self, name, BigDecimal, options)
        name                   = property.name.to_s
        instance_variable_name = property.instance_variable_name
        name_amount            = "#{name}_amount"
        name_currency          = "#{name}_currency"

        self.property name_amount.to_sym,   BigDecimal, property.options.except(:accessor, :reader, :writer).merge(:accessor => :private)
        self.property name_currency.to_sym, String,     :accessor => :private, :required => property.required, :length => 3

        # TODO: Access amount, currency via readers or properties?
        # TODO: Validations or error message attempting to set with something other than BigMoney?
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          #{property.reader_visibility}
          def #{name}
            return #{instance_variable_name} if defined?(#{instance_variable_name})
            return unless #{name_amount} && #{name_currency}
            #{instance_variable_name} = BigMoney.new(#{name_amount}, #{name_currency})
          end

          #{property.writer_visibility}
          def #{name}=(value)
            raise TypeError.new('Expected BigMoney +value+ but got \#{value.class}') unless value.kind_of?(BigMoney)
            self.#{name_amount}       = value.amount
            self.#{name_currency}     = value.currency
            #{instance_variable_name} = value
          end
        RUBY
      end

    end # ClassMethods

    Model.append_inclusions self
  end # Money
end # DataMapper
