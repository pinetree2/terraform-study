
resource "aws_wafv2_ip_set" "example" {
  name               = "song-waf"
  description        = "Example IP set"
  scope              = "REGIONAL" #scope는 CloudFront에 사용할 ACL이라면 CLOUDFRONT로 설정하고 그 외에 ALB, API Gateway에서 사용하는 ACL이라면 REGIONAL로 설정한다.
  ip_address_version = "IPV4"
  addresses          = ["127.0.0.1/32"] # 조건에서 제외시킬 ip 추가

}

# WAF 리소스 정의
resource "aws_wafv2_web_acl" "waf" {
  name        = "managed-rule-example"
  description = "Example of a managed rule."
  scope       = "REGIONAL"
  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  
  default_action {
    allow{} 
  }

  rule {
    name     = "rule-1"
    priority = 1

    override_action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = 1000 # 5분에 1000개의 request가 들어오면 조건에 성립한다.
        aggregate_key_type = "IP"
        scope_down_statement {
          not_statement {
            statement { 
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.example.arn
              }
            }
          }
        }
      }
    }

  }

  }
}



