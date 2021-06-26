var synthetics = require('Synthetics');
const log = require('SyntheticsLogger');

const apiCanaryBlueprint = async function () {

    // Handle validation for positive scenario
    const validateSuccessful = async function(res) {
        return new Promise((resolve, reject) => {
            if (res.statusCode != 200) {
                throw res.statusCode + ' ' + res.statusMessage;
            }

            let responseBody = '';
            res.on('data', (d) => {
                responseBody += d;
            });

            res.on('end', () => {
                // Add validation on 'responseBody' here if required.
                let body = JSON.parse(responseBody);
                let requiredFields = ['jsonrpc', 'id', 'result'];

                requiredFields.map(function(field){
                    if (!(field in body)) {
                        console.debug('body', body);
                        throw `${field} is missing in body`;
                    }
                });

                if (('error' in body)) {
                    throw 'error field exists in body';
                }

                resolve();
            });
        });
    };


    // Set request option for Verify hmyv2_getBalance
    let requestBody = {
      jsonrpc: '2.0',
      id: 1,
      method: 'hmyv2_getBalance',
      params: ['one15vlc8yqstm9algcf6e94dxqx6y04jcsqjuc3gt']
    };
    let requestOptionsStep1 = {
        hostname: 'rpc.s0.t.hmny.io',
        method: 'POST',
        path: '',
        port: '443',
        protocol: 'https:',
        body: JSON.stringify(requestBody),
        headers: {
            'Content-Type': 'application/json'
        }
    };
    requestOptionsStep1['headers']['User-Agent'] = [synthetics.getCanaryUserAgentString(), requestOptionsStep1['headers']['User-Agent']].join(' ');

    // Set step config option for Verify hmyv2_getBalance
   let stepConfig1 = {
        includeRequestHeaders: true,
        includeResponseHeaders: true,
        includeRequestBody: true,
        includeResponseBody: true,
        restrictedHeaders: [],
        continueOnHttpStepFailure: true
    };

    await synthetics.executeHttpStep('Verify hmyv2_getBalance', requestOptionsStep1, validateSuccessful, stepConfig1);


};

exports.handler = async () => {
    return await apiCanaryBlueprint();
};
