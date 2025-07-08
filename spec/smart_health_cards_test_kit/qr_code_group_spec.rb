RSpec.describe SmartHealthCardsTestKit::QrCodeGroup do
  let(:suite_id) { 'smart_health_cards' }
  # let(:request_repo) { Inferno::Repositories::Requests.new }
  # let(:group) { suite.groups.find { |g| g.id.include?('shc_qr_code_group')} }

  describe 'qr_code_verifiable_credential_test' do
    let(:test) { find_test suite, 'qr_code_verifiable_credential_test' }
    let(:url) { 'http://example.com/hc' }
    let(:qr_content) {'shc:/5676290952432060346029243740446031222959532654603460292540772804336028702864716745222809286128763439547745647128546471254525597432640408384254744505414152645533382437043827407152247568524333393942367434392060573601594130105371747424357443677141537267573029240552292822553332244125314009535422273625292231665300354073291259047065093326422729053423341023747655447743697337506833294126543362530800707676773242325504036932080645414171760504006033586242350620502762204173125205597704345442711007253106765622051245124228700725243777267657325926040056215623386603525006303537693361752838252569372731725026086154282776370435556857442506200430753070603665036523095455387159287170296676400421423624383260567644737523213000543330206359744569362209592321407524283325567444696322384206703968277372383154223857362845397306257040763363752969243362677335062856271103334175336264316812081004553704284262595404771230524050284040081062570656292623372811592974653158376800263952213833326050680322274565080325552971063143423170303603216736105341247550602420706552765807545027344231236676666070122221213704567374092836245228033808437456541268664060300966073100291138103938003000615270222624286876056475572150236356706806406059726755225908733145743173426740247158736431060305056857537553734370316271040577330343416059094006317539283034380923072805623506243250615022652344300558370445042927206710630855640005265545715667106255720675662655656428107369675043350045736511013106663423206512576827600964043569227640282159632530625977693159415610086160410755705258105840056745055703352643613723520358502906100358314228737707076410522145053471303436'}

    it 'passes if valid shc string is provided' do
      result = run(test, { qr_code_content: qr_content })

      expect(result.result).to eq('pass')
    end
  end

  # describe 'vci-file-02' do
  #   let(:test) { group.tests[1] }
  #   let(:url) { 'http://example.com/hc' }

  #   it 'passes if the response has the correct Content-Type header' do
  #     request_repo.create(
  #       status: 200,
  #       response_headers: [{ name: 'content-type', value: 'application/smart-health-card' }],
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )

  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('pass')
  #   end

  #   it 'skips if the vci_file_download request has not been made' do
  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('skip')
  #     expect(result.result_message).to match(/vci_file_download/)
  #   end

  #   it 'skips if a non-200 response was received' do
  #     request_repo.create(
  #       status: 500,
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )
  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('skip')
  #   end

  #   it 'fails if the response has an incorrect Content-Type header' do
  #     request_repo.create(
  #       status: 200,
  #       response_headers: [{ name: 'content-type', value: 'application/json' }],
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )

  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('fail')
  #     expect(result.result_message).to match(/Content-Type/)
  #   end

  #   it 'fails if the response has no Content-Type header' do
  #     request_repo.create(
  #       status: 200,
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )

  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('fail')
  #     expect(result.result_message).to match(/did not include/)
  #   end
  # end

  # describe 'vci-file-03' do
  #   let(:test) { group.tests[2] }
  #   let(:url) { 'http://example.com/hc' }

  #   it 'passes if the download url ends in .smart-health-card' do
  #     request_repo.create(
  #       status: 200,
  #       url: 'http://example.com/hc.smart-health-card',
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id
  #     )

  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('pass')
  #   end

  #   it 'skips if the vci_file_download request has not been made' do
  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('skip')
  #     expect(result.result_message).to match(/vci_file_download/)
  #   end

  #   it 'skips if a non-200 response was received' do
  #     request_repo.create(
  #       status: 500,
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )
  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('skip')
  #   end

  #   context 'with a url that does not end in .smart-health-card' do
  #     let(:url) { 'http://example.com/hc' }

  #     it 'passes if the response contains a Content-Disposition header with a .smart-health-card extension' do
  #       request_repo.create(
  #         status: 200,
  #         url: url,
  #         response_headers: [{ name: 'content-disposition', value: 'attachment; filename="hc.smart-health-card"' }],
  #         name: :vci_file_download,
  #         verb: 'get',
  #         direction: 'outgoing',
  #         test_session_id: test_session.id,
  #         result_id: repo_create(:result).id
  #       )

  #       result = run(test, { file_download_url: url })

  #       expect(result.result).to eq('pass')
  #     end

  #     it 'fails if no Content-Disposition header is received' do
  #       request_repo.create(
  #         status: 200,
  #         url: url,
  #         name: :vci_file_download,
  #         verb: 'get',
  #         direction: 'outgoing',
  #         test_session_id: test_session.id,
  #         result_id: repo_create(:result).id
  #       )
  #       result = run(test, { file_download_url: url })

  #       expect(result.result).to eq('fail')
  #     end

  #     it 'fails if Content-Disposition header does not indicate the file should be downloaded' do
  #       request_repo.create(
  #         status: 200,
  #         url: url,
  #         response_headers: [{ name: 'content-disposition', value: 'inline' }],
  #         name: :vci_file_download,
  #         verb: 'get',
  #         direction: 'outgoing',
  #         test_session_id: test_session.id,
  #         result_id: repo_create(:result).id
  #       )

  #       result = run(test, { file_download_url: url })

  #       expect(result.result).to eq('fail')
  #       expect(result.result_message).to match(/should be downloaded/)
  #     end

  #     it 'fails if Content-Disposition header does not indicate a .smart-health-card extension' do
  #       request_repo.create(
  #         status: 200,
  #         url: url,
  #         response_headers: [{ name: 'content-disposition', value: 'attachment; filename="hc.health-card"' }],
  #         name: :vci_file_download,
  #         verb: 'get',
  #         direction: 'outgoing',
  #         test_session_id: test_session.id,
  #         result_id: repo_create(:result).id
  #       )
  #       result = run(test, { file_download_url: url })

  #       expect(result.result).to eq('fail')
  #       expect(result.result_message).to match(/extension/)
  #     end
  #   end
  # end

  # describe 'vci-file-04' do
  #   let(:test) { group.tests[3] }
  #   let(:url) { 'http://example.com/hc' }

  #   it 'passes if the response contains an array of VC strings' do
  #     request_repo.create(
  #       status: 200,
  #       response_body: { 'verifiableCredential' => ['abc'] }.to_json,
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )

  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('pass')
  #   end

  #   it 'skips if the vci_file_download request has not been made' do
  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('skip')
  #     expect(result.result_message).to match(/vci_file_download/)
  #   end

  #   it 'skips if a non-200 response was received' do
  #     request_repo.create(
  #       status: 500,
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )
  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('skip')
  #   end

  #   it "fails if the body does not contain a 'verifiableCredential' field" do
  #     request_repo.create(
  #       status: 200,
  #       response_body: {}.to_json,
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )

  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('fail')
  #     expect(result.result_message).to match(/does not contain/)
  #   end

  #   it "fails if the 'verifiableCredential' field does not contain an array" do
  #     request_repo.create(
  #       status: 200,
  #       response_body: { 'verifiableCredential' => 'abc' }.to_json,
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )

  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('fail')
  #     expect(result.result_message).to match(/must contain an Array/)
  #   end

  #   it "fails if the 'verifiableCredential' field contains an empty array" do
  #     request_repo.create(
  #       status: 200,
  #       response_body: { 'verifiableCredential' => [] }.to_json,
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )

  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('fail')
  #     expect(result.result_message).to match(/at least one/)
  #   end
  # end
end
