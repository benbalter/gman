# frozen_string_literal: true

RSpec.describe Gman::Locality do
  context 'valid domains' do
    ['foo.state.il.us', 'ci.foo.il.us'].each do |domain|
      context "the #{domain} domain" do
        it 'is valid' do
          expect(described_class.valid?(domain)).to be(true)
        end
      end
    end
  end

  context 'invalid domains' do
    ['state.foo.il.us', 'foo.ci.il.us',
     'k12.il.us', 'ci.foo.zx.us'].each do |domain|
       context "the #{domain} domain" do
         it 'is invalid' do
           expect(described_class.valid?(domain)).to be(false)
         end
       end
     end
  end
end
