# encoding: utf-8
module Mongoid
  module Persistable

    # Defines behaviour for $pull and $pullAll operations.
    #
    # @since 4.0.0
    module Pullable
      extend ActiveSupport::Concern

      # Pull single values from the provided arrays.
      #
      # @example Pull a value from the array.
      #   document.pull(names: "Jeff", levels: 5)
      #
      # @note If duplicate values are found they will all be pulled.
      #
      # @param [ Hash ] pulls The field/value pull pairs.
      #
      # @return [ true, false ] If the operation succeeded.
      #
      # @since 4.0.0
      def pull(pulls)
        prepare_atomic_operation do |coll, selector, ops|
          pulls.each do |field, value|
            normalized = database_field_name(field)
            (send(field) || []).delete(value)
            remove_change(normalized)
            ops[atomic_attribute_name(normalized)] = value
          end
          coll.find(selector).update(positionally(selector, "$pull" => ops))
        end
      end

      # Pull multiple values from the provided array fields.
      #
      # @example Pull values from the arrays.
      #   document.pull_all(names: [ "Jeff", "Bob" ], levels: [ 5, 6 ])
      #
      # @param [ Hash ] pulls The pull all operations.
      #
      # @return [ true, false ] If the operation succeeded.
      #
      # @since 4.0.0
      def pull_all(pulls)
        prepare_atomic_operation do |coll, selector, ops|
          pulls.each do |field, value|
            normalized = database_field_name(field)
            existing = send(field) || []
            value.each{ |val| existing.delete(val) }
            remove_change(normalized)
            ops[atomic_attribute_name(normalized)] = value
          end
          coll.find(selector).update(positionally(selector, "$pullAll" => ops))
        end
      end
    end
  end
end
