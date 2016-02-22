require 'spec_helper'

describe Magelex::TaxGuess do
  it 'guesses 0 % right' do
    expect(Magelex::TaxGuess.guess(119, 0)).to be :tax0
  end
  it 'guesses 7 % right' do
    expect(Magelex::TaxGuess.guess(107, 7)).to be :tax7
  end
  it 'guesses 19 % right' do
    expect(Magelex::TaxGuess.guess(119, 19)).to be :tax19
  end
end
