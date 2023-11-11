# frozen_string_literal: true

require_relative '../column'

module SchemaToHash
  module Fetchers
    class Columns
      def initialize(db:, table_name:)
        @db = db
        @table_name = table_name
      end

      def all
        result = db.exec(sql)

        result.map do |row|
          Column.new(
            name: row['column_name'],
            default: row['column_default'],
            nullable: row['is_nullable'] == 'YES' ? true : false,
            type: row['data_type'],
            comment: row['column_description']
          )
        end
      end

      private

      attr_reader :db, :schema, :table_name

      def sql
        <<-SQL
          SELECT
            table_name,
            column_name,
            column_default,
            is_nullable,
            data_type,
            col_description(table_name::regclass, ordinal_position) AS column_description
          FROM
            information_schema.columns
          WHERE
            table_name = '#{table_name}'
          ORDER BY
            ordinal_position;
        SQL
      end
    end
  end
end
