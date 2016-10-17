RSpec.describe 'Gman domains' do
  let(:resolve_domains?) { ENV['GMAN_RESOLVE_DOMAINS'] == 'true' }
  let(:importer) { Gman::Importer.new({}) }
  let(:options) { { skip_dupe: true, skip_resolve: !resolve_domains? } }

  Gman.list.to_h.each do |group, domains|
    next if ['non-us gov', 'non-us mil', 'US Federal'].include?(group)

    context "the #{group} group" do
      it 'only contains valid domains' do
        invalid_domains = []

        Parallel.each(domains, in_threads: 4) do |domain|
          next if importer.valid_domain?(domain, options)
          invalid_domains.push domain
        end

        expect(invalid_domains).to be_empty
      end
    end
  end
end
