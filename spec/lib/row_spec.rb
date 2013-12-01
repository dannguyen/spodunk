require 'spec_helper'


describe "Spodunk::Row" do

  let(:headers){ %w(Apples Oranges Blue-kiwi) }
  let(:values){ [20, 9, 'none'] }

  before{ @row = Row.new(values, headers)}

  describe 'initialization' do
    it 'should accept values and headers array and make a mash' do
      expect(@row).to be_a Row
      expect(@row.mash).to be_a Hashie::Mash
      expect(@row.original).to be_a Hashie::Mash
    end
 
    it 'should delegate values and keys to the @mash' do
      expect(@row.values).to eq values
      expect(@row.keys).to eq headers
    end

    it 'should have #original_values' do
      expect(@row.original_values).to eq values
    end

    it 'should allow access by column index by delegating to @values' do
      expect(@row[1]).to eq 9
    end

    it 'should be timestamped' do
      expect(@row.timestamp).to be_within(10).of(Time.now)
    end
  end

  context 'changes' do
    before do
      @row[0] = 20 # no change
      @row[1] = 200
      @row[2] = nil
    end

    describe 'dirty?' do
      it 'should be true if anything has changed' do
        @row[1] = 20
        expect(@row).to be_dirty
      end
    end

    describe 'diff' do
      it 'should list all changes' do
        expect(@row.diff).to eq({
          'Oranges' => [9, 200],
          'Blue-kiwi' => ['none', nil] 
        })      
      end
    end

    describe '#changes' do
      it 'by default, returns a Hash header-names as keys' do
        expect(@row.changes).to eq({
          'Oranges' => 200,
          'Blue-kiwi' => nil
        })        
      end

      it 'should take :offset option' do
        expect(@row.changes(offset: 0)).to eq({
            1 => 200,
            2 => nil
          }
        )

        expect(@row.changes(offset: 1)).to eq({
            2 => 200,
            3 => nil
          }
        )

      end

    end
  end
end
