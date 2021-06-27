var synthetics = require('Synthetics');
const log = require('SyntheticsLogger');

const apiCanaryBlueprint = async function () {

    // Handle validation for positive scenario
    const validateSuccessful = async function(res) {
        return new Promise((resolve, reject) => {
            if (res.statusCode < 200 || res.statusCode > 299) {
                throw res.statusCode + ' ' + res.statusMessage;
            }

            let responseBody = '';
            res.on('data', (d) => {
                responseBody += d;
            });

            res.on('end', () => {
                // Add validation on 'responseBody' here if required.
                let body = JSON.parse(responseBody);
                log.debug('Got body:', body);

                let requiredFields = ['jsonrpc', 'id'];
                requiredFields.map(function(field){
                    if (!(field in body)) {
                        console.debug('body', body);
                        throw `${field} is missing in body`;
                    }
                });

                let error = body.error;
                if (error.message != 'insufficient funds for gas * price + value') {
                    throw `Expecting insfficient funds error, got error: ${JSON.stringify(body.error)}`;
                }

                resolve();
            });
        });
    };


    let requestBody = {
        jsonrpc: '2.0',
        id: 1,
        method: 'hmyv2_sendRawTransaction',
      params: [
        '0xf8692685174876e80083033450808094d6ba69da5b45ec98b53e3258d7de756a567b67638227108026a0dabadb2eea98ee44e85222a2bb44c1662eec9a7be86057054769c94618515ba6a00d9a4e41efe1f15c06c191a65612487ccd5ea6d75843bd33b4b823e9841cc616'
              ]
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

   let stepConfig1 = {
        includeRequestHeaders: true,
        includeResponseHeaders: true,
        includeRequestBody: true,
        includeResponseBody: true,
        restrictedHeaders: [],
        continueOnHttpStepFailure: true
    };

    await synthetics.executeHttpStep('Verify hmyv2_getAllValidatorInformation', requestOptionsStep1, validateSuccessful, stepConfig1);


};

exports.handler = async () => {
    return await apiCanaryBlueprint();
};
