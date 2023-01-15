// Configure the SNS topic to which Chainguard will subscribe for
// audit logging events.
resource "aws_sns_topic" "chainguard_auditlogs" {
  name = "chainguard-auditlogs"
}

// This configures CloudWatch to monitor events coming from ECS
resource "aws_cloudwatch_event_rule" "ecs" {
  name        = "chainguard-ecs-auditlogs"
  description = "Capture ECS events that Chainguard Enforce needs to monitor"

  event_pattern = jsonencode({
    "source" : [
      "aws.ecs"
    ],
    "detail-type" : [
      "ECS Task State Change",
      "ECS Container Instance State Change",
      "ECS Deployment State Change"
    ]
  })
}
resource "aws_cloudwatch_event_target" "ecs" {
  rule = aws_cloudwatch_event_rule.ecs.name
  arn  = aws_sns_topic.chainguard_auditlogs.arn
}

// This configures CloudWatch to monitor events coming from AppRunner
resource "aws_cloudwatch_event_rule" "apprunner" {
  name        = "chainguard-apprunner-auditlogs"
  description = "Capture AppRunner events that Chainguard Enforce needs to monitor"

  event_pattern = jsonencode({
    "source" : [
      "aws.apprunner"
    ],
    "detail-type" : [
      "AppRunner Service Status Change",
      "AppRunner Service Operation Status Change"
    ]
  })
}
resource "aws_cloudwatch_event_target" "apprunner" {
  rule = aws_cloudwatch_event_rule.apprunner.name
  arn  = aws_sns_topic.chainguard_auditlogs.arn
}

// Allow any CloudWatch event rules configured above to publish to the
// auditlog SNS topic.
resource "aws_sns_topic_policy" "chainguard_auditlogs" {
  arn = aws_sns_topic.chainguard_auditlogs.arn
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "snspolicy",
    "Statement" : [
      {
        "Sid" : "First",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "events.amazonaws.com"
        },
        "Action" : "sns:Publish",
        "Resource" : aws_sns_topic.chainguard_auditlogs.arn,
        "Condition" : {
          "ArnEquals" : {
            "aws:SourceArn" : [
              aws_cloudwatch_event_rule.ecs.arn,
              aws_cloudwatch_event_rule.apprunner.arn,
            ]
          }
        }
      }
    ]
  })
}
