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
 
    it 'should delegate values and in the @mash' do
      expect(@row.values).to eq values
    end

    it 'should delegate keys to @mash, but @mash has them slugified' do
      expect(@row.keys).to eq headers.map{|h| h.slugify}
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
          'oranges' => [9, 200],
          'blue_kiwi' => ['none', nil] 
        })      
      end
    end

    describe '#changes' do
      it 'by default, returns a Hash header-names as keys' do
        expect(@row.changes).to eq({
          'oranges' => 200,
          'blue_kiwi' => nil
        })        
      end

      it 'should take :offset option' do
        expect(@row.changes(col_offset: 0)).to eq({
            1 => 200,
            2 => nil
          }
        )
      end

      it 'should have #itemized_changes as convenience' do
        expect(@row.itemized_changes).to eq({
            2 => 200,
            3 => nil
          }
        )

        expect(@row.itemized_changes).to eq @row.changes(col_offset: 1)
      end
    end
  end

  context '#attributes' do
    let(:headers){ %w(Apples Oranges Blue-kiwi) }
    let(:values){ [20, 9, 'none'] }

    before{ @row = Row.new(values, headers)}

    it 'should be the same as @mash, with string keys' do 
      expect(@row.attributes).to eq @row.mash.stringify_keys
    end

    describe '#has_attribute?' do
      it 'checks on string equality' do
        expect(@row.has_attribute?('Blue-kiwi')).to be_true
        expect(@row.has_attribute?('blue_kiwi')).to be_true
        expect(@row.has_attribute?('red_kiwi')).to be_false

        # note, headers are slugified at the Table level
        # not when we initialize rows manually
      end
    end


    describe '#assign_attributes' do
      it 'should modify the row' do
        @row.assign_attributes('Blue-kiwi' => 5)
        expect(@row).to be_dirty
        expect(@row.attributes['blue_kiwi']).to eq 5
      end

      it 'should work with slugified attributes' do
        @row.assign_attributes('blue_kiwi' => 'yay')

        expect(@row.attributes['blue_kiwi']).to eq 'yay'
      end

      it 'should silently ignore non-existent attributes' do
        @row.assign_attributes('nothing_here' => 99)
        expect(@row.attributes['nothing_here']).to be_nil
        expect(@row).not_to be_dirty
      end
    end
  end



end
