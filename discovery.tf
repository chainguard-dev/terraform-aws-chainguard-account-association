resource "aws_iam_role" "discovery_role" {
  name = "chainguard-discovery"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Federated" : aws_iam_openid_connect_provider.chainguard_idp.arn
      },
      "Action" : "sts:AssumeRoleWithWebIdentity",
      "Condition" : {
        "StringEquals" : {
          // This role may only be impersonated by Chainguard's "discovery"
          // components, which mints tokens suitable for talking to EKS
          // clusters.  We are authorizing components nested under GROUP
          // to perform this impersonation.
          "issuer.${var.enforce_domain_name}:sub" : [for id in local.enforce_group_ids : "discovery:${id}"]
          // Tokens must be intended for use with Amazon.
          "issuer.${var.enforce_domain_name}:aud" : "amazon"
        }
      }
    }]
  })
}

// Our discovery role needs to list available regions, and resources within
// those regions as part of its discovery scanning.  Currently this allows
// us to discovery EKS and ECS resources.
resource "aws_iam_policy" "chainguard_discovery_policy" {
  name        = "chainguard-discovery-policy"
  description = "A policy to allow Chainguard to list and describe resources."
  policy      = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "ec2:DescribeRegions",

                    "eks:ListClusters",
                    "eks:DescribeCluster",

                    "ecs:ListServicesByNamespace",
                    "ecs:ListAttributes",
                    "ecs:ListServices",
                    "ecs:ListAccountSettings",
                    "ecs:ListTagsForResource",
                    "ecs:ListTasks",
                    "ecs:ListTaskDefinitionFamilies",
                    "ecs:ListContainerInstances",
                    "ecs:ListTaskDefinitions",
                    "ecs:ListClusters",
                    "ecs:DescribeTaskSets",
                    "ecs:DescribeTaskDefinition",
                    "ecs:DescribeClusters",
                    "ecs:DescribeCapacityProviders",
                    "ecs:DescribeServices",
                    "ecs:DescribeContainerInstances",
                    "ecs:DescribeTasks"
                ],
                "Resource": "*"
            }
        ]
    }
  EOF
}

// The permissions to grant the "discovery" role.
resource "aws_iam_role_policy_attachment" "discovery_cluster_viewer" {
  role       = aws_iam_role.discovery_role.name
  policy_arn = aws_iam_policy.chainguard_discovery_policy.arn
}
