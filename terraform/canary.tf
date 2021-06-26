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
      "expected_result" : "\"0x\""
    },
    "estimate_gas" : {
      "method" : "hmyv2_estimateGas",
      "params" : [
        { "to" : "0x08AE1abFE01aEA60a47663bCe0794eCCD5763c19" },
      ],
      "result_type" : "string",
      "expected_result" : "\"0x5208\""
    },
    "get_code" : {
      "method" : "hmyv2_getCode"
      "params" : [
        "0x08AE1abFE01aEA60a47663bCe0794eCCD5763c19",
        370000
      ],
      "result_type" : "string",
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

    "get_balance" : {
      "method" : "hmyv2_getBalance"
      "params" : ["one15vlc8yqstm9algcf6e94dxqx6y04jcsqjuc3gt"],
      "result_type" : "number",
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
      "expected_result" : "\"0x\""
    },
  }

  timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
}

data "archive_file" "canary_zip_inline" {
  for_each    = local.rpc_methods
  type        = "zip"
  output_path = "/tmp/canary_zip_inline-${each.key}-${local.timestamp}.zip"
  source {
    content = fileexists("${path.module}/scripts/${each.key}.js") ? (
      file("${path.module}/scripts/${each.key}.js")
      ) : (templatefile("${path.module}/templates/generic_test.tmpl.js", {
        api_endpoint    = local.hosts[0]
        method          = each.value.method
        params          = jsonencode(each.value.params)
        result_type     = each.value.result_type
        expected_result = each.value.expected_result
      })
    )
    filename = "nodejs/node_modules/apiCanaryBlueprint.js"
  }
}

resource "aws_synthetics_canary" "main" {
  for_each             = local.rpc_methods
  name                 = each.key
  artifact_s3_location = "s3://${var.s3}/canary/${each.key}"
  execution_role_arn   = aws_iam_role.main.arn
  handler              = "apiCanaryBlueprint.handler"
  # TODO change this
  start_canary = true
  # start_canary    = false
  zip_file        = "/tmp/canary_zip_inline-${each.key}-${local.timestamp}.zip"
  runtime_version = "syn-nodejs-puppeteer-3.1"

  run_config {
    active_tracing     = true
    timeout_in_seconds = 60
  }

  schedule {
    expression = "rate(5 minutes)"
  }
}
