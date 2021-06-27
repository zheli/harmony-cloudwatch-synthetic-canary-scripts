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

                if (('error' in body)) {
                    throw `Found error in response! Error: ${JSON.stringify(body.error)}`;
                }

                let requiredFields = ['jsonrpc', 'id', 'result'];
                requiredFields.map(function(field){
                    if (!(field in body)) {
                        console.debug('body', body);
                        throw `${field} is missing in body`;
                    }
                });

                let result = body.result;
                if ("object" !== typeof result) {
                    throw `result type: ${typeof result}, should be "object"`;
                }

                if (result.length == 0) {
                    throw `there should be more than 0 validators available`;
                }

                let firstValidatorActiveStatus = result[0]['active-status'];
                if (firstValidatorActiveStatus != 'active' && firstValidatorActiveStatus != 'inactive') {
                    throw `First validator status should either be active or inactive, result[0]=${JSON.stringify(result[0])}`;
                }

                resolve();
            });
        });
    };


    let requestBody = {
        jsonrpc: '2.0',
        id: 1,
        method: 'hmyv2_getAllValidatorInformation',
        params: [0]
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
