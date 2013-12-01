require 'spec_helper'

describe Spodunk::Table do

  context 'basic ops' do 
    let(:rows){[ 
      ['Hello', 'world', "It's me"],
      ['a', 1, "99"]
    ]}
    before do
      @table = Table.new(rows)
    end

    describe 'initialization by rows' do
      it 'should accept array as first argument ' do
        expect(@table).to be_a Table
      end

      it 'should not modify original array' do
        expect(rows.count).to eq 2
      end
    end

    describe '@headers' do
      it 'should by default be first row' do
        expect(@table.headers).to eq rows.first
      end
    end

    describe '@rows' do
      it 'should convert all rows to SpreadtableBoss::Row' do
        expect(@table.rows.all?{|r| r.is_a?(Row)})
      end

      it 'should same as source arr, minus headers' do
        expect(@table.rows[0].values).to eq rows.last
      end      
    end
  end


  describe 'validation' do
    it 'should not allow headers with same sluggable name'
    
  end

  describe 'configuration' do
    it 'should have a unique key field'
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

      it '#worksheet_changes should list changes with 1-based index and col numbers' do
        expect(@table.worksheet_changes).to eq({
          1 => { 2 => 'changed'}
        })
      end

      it '#itemized_changes should be Hash with [row,col] as keys' do
        expect(@table.itemized_changes).to eq({
          [1,2] => 'changed'
        })
      end


    end
  end



end