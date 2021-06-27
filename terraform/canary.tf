locals {
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
        verify_result   = each.value.verify_result
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
