# frozen_string_literal: true

RSpec.describe 'Gman Country Codes' do
  {
    'whitehouse.gov' => 'United States of America',
    'foo.gov.uk' => 'United Kingdom of Great Britain and Northern Ireland',
    'army.mil' => 'United States of America',
    'foo.gc.ca' => 'Canada',
    'foo.eu' => nil
  }.each do |domain, expected_country|
    context "given #{domain.inspect}" do
      subject { Gman.new(domain) }

      let(:country) { subject.country }

      it 'knows the country' do
        if expected_country.nil?
          expect(country).to be_nil
        else
          expect(country.name).to eql(expected_country)
        end
      end

      it 'knows the alpha2' do
        expected = case expected_country
                   when 'United States of America'
                     'us'
                   when 'Canada'
                     'ca'
                   when 'United Kingdom of Great Britain and Northern Ireland'
                     'gb'
                   else
                     'eu'
                   end
        expect(subject.alpha2).to eql(expected)
      end
    end
  end
end
