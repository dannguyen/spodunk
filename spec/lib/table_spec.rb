require 'spec_helper'

describe Spodunk::Table do
  let(:connection){ Connection::Base.new}

  context 'basic ops' do 
    let(:rows){[ 
      ['Hello', 'world', "It's me"],
      ['a', 1, "99"]
    ]}
    before do
      @table = Table.new(rows, connection: connection)
    end

    describe 'binding to Spodunk things' do 
      it 'should have a @connection' do
        expect(@table.connection).to be_a Connection::Base
      end
    end

    describe 'initialization by rows' do
      it 'should accept array as first argument ' do
        expect(@table).to be_a Table
      end

      it 'should not modify original array' do
        expect(rows.count).to eq 2
      end
    end

    describe 'rows and indicies' do
      it 'should have basic counts' do
        expect(@table.num_rows).to eq 1
        expect(@table.num_cols).to eq 3
      end

      describe '#real_row_index' do
        it 'by default has @row_offset of 2' do
          expect(@table.row_offset).to eq 2
        end
    
        it 'by default has @col_offset of 1' do 
          expect(@table.col_offset).to eq 1
        end

        it 'uses @row_offset in real_row_index' do
          expect(@table.real_row_index(0)).to eq 2
        end

        it 'can take in a Spodunk::Row as argument' do
          row = @table.rows.first

          expect(@table.real_row_index(row)).to eq 2
        end
      end
    end

    describe '@headers' do
      it 'should by default be first row' do
        expect(@table.headers).to eq rows.first
      end
    end

    describe '@rows' do
      it 'should convert all rows to SpreadtableConnection::Row' do
        expect(@table.rows.all?{|r| r.is_a?(Row)})
      end

      it 'should same as source arr, minus headers' do
        expect(@table.rows[0].values).to eq rows.last
      end      
    end
  end


  describe 'validation' do
    it 'should be valid? if all headers are sluggibly unique' do
      table = Table.new([
        ['hey you', 'hey- there'],
        [1,2]
      ])

      expect(table).to be_valid
    end

    it 'should not allow headers with same sluggable name' do
      table = Table.new([
        ['hey you', 'hey-you   '],
        [1,2]
      ])

      expect(table).not_to be_valid
    end    
  end

  describe 'configuration' do

  end

  describe 'factory methods' do
    describe 'initialization with a key' do


    end
  end


  context 'dirtiness' do
    let(:rows){[ 
      ['Hello', 'world', "It's me"],
      ['a', 1, "99"]
    ]}

    before do
      @table = Table.new(rows)
      @row = @table.rows.first
      @row['world'] = 'changed'
    end

    it 'should be #dirty?' do
      expect(@table).to be_dirty
    end

    describe '#changes' do
      it 'should list changes' do
        expect(@table.changes).to eq({
          0 => {'world' => 'changed'}
        })
      end

      it '#offset_changes should list changes with 1-based index and col numbers' do
        expect(@table.offset_changes).to eq({
          2 => { 2 => 'changed'}
        })
      end

      it '#itemized_changes should be Hash with [row,col] as keys' do
        expect(@table.itemized_changes).to eq({
          [2,2] => 'changed'
        })
      end


    end
  end



end