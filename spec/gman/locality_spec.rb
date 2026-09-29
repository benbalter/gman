# frozen_string_literal: true

RSpec.describe Gman::Locality do
  context 'valid domains' do
    ['foo.state.il.us', 'ci.foo.il.us', 'state.il.us', 'www.ci.foo.il.us',
     'ci.austin.tx.us', 'sub.co.somewhere.ca.us', 'dst.ny.us', 'cog.ca.us'].each do |domain|
      context "the #{domain} domain" do
        it 'is valid' do
          expect(described_class.valid?(domain)).to be(true)
        end
      end
    end
  end

  context 'invalid domains' do
    ['state.foo.il.us', 'foo.ci.il.us',
     'k12.il.us', 'ci.foo.zx.us', 'state.il.us.attacker.com',
     'ci.foo.il.us.attacker.com', 'state.ca.usattacker.com',
     'state.ca.usa-attacker.com', 'dst.ny.us.evil.co.uk',
     'notastate.il.us', 'xci.foo.il.us', 'state.il.us-attacker.com'].each do |domain|
       context "the #{domain} domain" do
         it 'is invalid' do
           expect(described_class.valid?(domain)).to be(false)
         end
       end
     end
  end
end
