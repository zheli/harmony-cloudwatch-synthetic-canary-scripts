locals {
  hosts = [
    "rpc.s0.t.hmny.io",
    "rpc.s1.t.hmny.io"
  ]

  rpc_methods = {
    # smart contract
    "call" : {
      "method" : "hmyv2_call"
      "params" : [
        { "to" : "0x08AE1abFE01aEA60a47663bCe0794eCCD5763c19" },
        370000
      ],
      "result_type" : "string",
      "verify_result" : true
      "expected_result" : "\"0x\""
    },
    "estimate_gas" : {
      "method" : "hmyv2_estimateGas",
      "params" : [
        { "to" : "0x08AE1abFE01aEA60a47663bCe0794eCCD5763c19" },
      ],
      "result_type" : "string",
      "verify_result" : true
      "expected_result" : "\"0x5208\""
    },
    "get_code" : {
      "method" : "hmyv2_getCode"
      "params" : [
        "0x08AE1abFE01aEA60a47663bCe0794eCCD5763c19",
        370000
      ],
      "result_type" : "string",
      "verify_result" : true
      "expected_result" : "\"0xDEADBEEF\""
    },
    "get_storage_at" : {
      "method" : "hmyv2_getStorageAt"
      "params" : [
        "0x295a70b2de5e3953354a6a8344e616ed314d7251",
        "0x0",
        370000
      ],
      "result_type" : "string",
      "verify_result" : true
      "expected_result" : "\"0x0000000000000000000000000000000000000000000000000000000000000000\""
    },

    # staking - delegation
    # CloudWatch canary max length is 21
    "delegations_by_delega" : {
      "method" : "hmyv2_getDelegationsByDelegator",
      "params" : [
        "one1t593eqff9h2cjxz2k7d6q4cg4zmmgtm9veeyd9"
      ]
      "result_type" : "object",
      "verify_result" : true
      "expected_result" : jsonencode([
        {
          "Undelegations" : [],
          "amount" : 0,
          "delegator_address" : "one1t593eqff9h2cjxz2k7d6q4cg4zmmgtm9veeyd9",
          "reward" : 0,
          "validator_address" : "one1r3kwetfy3ekfah75qaedwlc72npqm2gkayn6ue"
        },
        {
          "Undelegations" : [],
          "amount" : 0,
          "delegator_address" : "one1t593eqff9h2cjxz2k7d6q4cg4zmmgtm9veeyd9",
          "reward" : 0,
          "validator_address" : "one14wyp73qmn3zch98dqnjvu4rprcz79tlrxq3al6"
        },
        {
          "Undelegations" : [],
          "amount" : 0,
          "delegator_address" : "one1t593eqff9h2cjxz2k7d6q4cg4zmmgtm9veeyd9",
          "reward" : 0,
          "validator_address" : "one1kf42rl6yg2avkjsu34ch2jn8yjs64ycn4n9wdj"
        },
        {
          "Undelegations" : [],
          "amount" : 0,
          "delegator_address" : "one1t593eqff9h2cjxz2k7d6q4cg4zmmgtm9veeyd9",
          "reward" : 0,
          "validator_address" : "one18xrw6c8a7hrrpxayflmsgwq9k5rxhfqjgsqdd5"
        }
      ])
    },
    "del_by_del_by_block" : {
      "method" : "hmyv2_getDelegationsByDelegatorByBlockNumber",
      "params" : [
        "one1t593eqff9h2cjxz2k7d6q4cg4zmmgtm9veeyd9",
        3700000
      ]
      "result_type" : "object",
      "verify_result" : true
      "expected_result" : jsonencode([
        {
          "Undelegations" : [],
          "amount" : 6.90098018e+23,
          "delegator_address" : "one1t593eqff9h2cjxz2k7d6q4cg4zmmgtm9veeyd9",
          "reward" : 707732421124633500000,
          "validator_address" : "one1r3kwetfy3ekfah75qaedwlc72npqm2gkayn6ue"
        },
        {
          "Undelegations" : [],
          "amount" : 5.17573513487e+23,
          "delegator_address" : "one1t593eqff9h2cjxz2k7d6q4cg4zmmgtm9veeyd9",
          "reward" : 530186649349346950000,
          "validator_address" : "one14wyp73qmn3zch98dqnjvu4rprcz79tlrxq3al6"
        },
        {
          "Undelegations" : [],
          "amount" : 5.17573e+23,
          "delegator_address" : "one1t593eqff9h2cjxz2k7d6q4cg4zmmgtm9veeyd9",
          "reward" : 519118543630209100000,
          "validator_address" : "one1kf42rl6yg2avkjsu34ch2jn8yjs64ycn4n9wdj"
        }
      ])
    },
    "del_by_validator" : {
      "method" : "hmyv2_getDelegationsByValidator",
      "params" : [
        "one1qk7mp94ydftmq4ag8xn6y80876vc28q7s9kpp7"
      ]
      "result_type" : "object",
      "verify_result" : true
      "expected_result" : jsonencode(local.expected_result["hmyv2_getDelegationsByValidator"])
    },
    # staking - validator
    # test is in all_validator_addresses.js script, the fields in this map are ignored
    "all_validator_address" : {
      "method" : "",
      "params" : [],
      "result_type" : "",
      "verify_result" : true
      "expected_result" : ""
    },
    # test is in all_validator_info.js script, the fields in this map are ignored
    "all_validator_info" : {
      "method" : "",
      "params" : [],
      "result_type" : "",
      "verify_result" : true
      "expected_result" : ""
    },
    # test is in all_validator_inf_blo.js script, the fields in this map are ignored
    "all_validator_inf_blo" : {
      "method" : "",
      "params" : [],
      "result_type" : "",
      "verify_result" : true
      "expected_result" : ""
    },
    # test is in elected_validatoraddr.js script, the fields in this map are ignored
    "elected_validatoraddr" : {
      "method" : "",
      "params" : [],
      "result_type" : "",
      "verify_result" : true
      "expected_result" : ""
    },
    # test is in validator_information.js script, the fields in this map are ignored
    "validator_information" : {
      "method" : "",
      "params" : [],
      "result_type" : "",
      "verify_result" : true
      "expected_result" : ""
    },
    "get_balance" : {
      "method" : "hmyv2_getBalance"
      "params" : ["one15vlc8yqstm9algcf6e94dxqx6y04jcsqjuc3gt"],
      "result_type" : "number",
      "verify_result" : true
      "expected_result" : 12001989979000000000000
    },
    # for testing
    "error-test" : {
      "method" : "hmyv2_call"
      "params" : [
        { "to" : "0x123" },
        370000
      ],
      "result_type" : "string",
      "verify_result" : true
      "expected_result" : "\"0x\""
    },
  }
}
