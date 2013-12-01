require 'spec_helper'

describe 'conveniences' do


  describe 'slugify' do
    it 'should underscore and strip' do 
      expect('Hey'.slugify).to eq 'hey'
      expect('heyYou'.slugify).to eq 'hey_you'
      expect('Hey you'.slugify).to eq 'hey_you'
      expect('Hey ! !!! you!  !'.slugify).to eq 'hey_you'
      expect('hey_you'.slugify).to eq 'hey_you'
    end
  end

end