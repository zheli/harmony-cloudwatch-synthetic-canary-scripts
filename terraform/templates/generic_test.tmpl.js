var synthetics = require('Synthetics');
const log = require('SyntheticsLogger');

function deepCompare () {
  var i, l, leftChain, rightChain;

  function compare2Objects (x, y) {
    var p;

    // remember that NaN === NaN returns false
    // and isNaN(undefined) returns true
    if (isNaN(x) && isNaN(y) && typeof x === 'number' && typeof y === 'number') {
         return true;
    }

    // Compare primitives and functions.
    // Check if both arguments link to the same object.
    // Especially useful on the step where we compare prototypes
    if (x === y) {
        return true;
    }

    // Works in case when functions are created in constructor.
    // Comparing dates is a common scenario. Another built-ins?
    // We can even handle functions passed across iframes
    if ((typeof x === 'function' && typeof y === 'function') ||
       (x instanceof Date && y instanceof Date) ||
       (x instanceof RegExp && y instanceof RegExp) ||
       (x instanceof String && y instanceof String) ||
       (x instanceof Number && y instanceof Number)) {
        return x.toString() === y.toString();
    }

    // At last checking prototypes as good as we can
    if (!(x instanceof Object && y instanceof Object)) {
        return false;
    }

    if (x.isPrototypeOf(y) || y.isPrototypeOf(x)) {
        return false;
    }

    if (x.constructor !== y.constructor) {
        return false;
    }

    if (x.prototype !== y.prototype) {
        return false;
    }

    // Check for infinitive linking loops
    if (leftChain.indexOf(x) > -1 || rightChain.indexOf(y) > -1) {
         return false;
    }

    // Quick checking of one object being a subset of another.
    // todo: cache the structure of arguments[0] for performance
    for (p in y) {
        if (y.hasOwnProperty(p) !== x.hasOwnProperty(p)) {
            return false;
        }
        else if (typeof y[p] !== typeof x[p]) {
            return false;
        }
    }

    for (p in x) {
        if (y.hasOwnProperty(p) !== x.hasOwnProperty(p)) {
            return false;
        }
        else if (typeof y[p] !== typeof x[p]) {
            return false;
        }

        switch (typeof (x[p])) {
            case 'object':
            case 'function':

                leftChain.push(x);
                rightChain.push(y);

                if (!compare2Objects (x[p], y[p])) {
                    return false;
                }

                leftChain.pop();
                rightChain.pop();
                break;

            default:
                if (x[p] !== y[p]) {
                    return false;
                }
                break;
        }
    }

    return true;
  }

  if (arguments.length < 1) {
      throw "Need two or more arguments to compare";
  }

  for (i = 1, l = arguments.length; i < l; i++) {

      leftChain = []; //Todo: this can be cached
      rightChain = [];

      if (!compare2Objects(arguments[0], arguments[i])) {
          return false;
      }
  }

  return true;
}

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
                    throw `Found error in response! Error: $${JSON.stringify(body.error)}`;
                }

                let requiredFields = ['jsonrpc', 'id', 'result'];
                requiredFields.map(function(field){
                    if (!(field in body)) {
                        console.debug('body', body);
                        throw `$${field} is missing in body`;
                    }
                });

                let result = body.result;
                let resultType = "${result_type}";
                let verifyResult = ${verify_result};
                if (resultType != (typeof result)) {
                    throw `expected resultType: $${resultType}, got type: $${typeof result}. Result=$${result}`;
                }
                if (verifyResult) {
                    let expectedResult = ${expected_result};
                    switch (resultType) {
                    case 'object':
                        if (!deepCompare(expectedResult, result)) {
                            throw `expected result: $${JSON.stringify(expectedResult)}, got $${JSON.stringify(result)}`;
                        }
                        break;
                    default:
                        if (expectedResult !== result) {
                            throw `expected result: $${expectedResult}, got $${result}`;
                        }
                    }
                }

                resolve();
            });
        });
    };


    // Set request option for Verify hmyv2_getBalance
    let requestBody = {
        jsonrpc: '2.0',
        id: 1,
        method: '${method}',
        params: ${params}
    };
    let requestOptionsStep1 = {
        hostname: '${api_endpoint}',
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

    await synthetics.executeHttpStep('Verify hmyv2_${method}', requestOptionsStep1, validateSuccessful, stepConfig1);


};

exports.handler = async () => {
    return await apiCanaryBlueprint();
};
