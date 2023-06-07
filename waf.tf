# WAF 리소스 정의
resource "aws_waf_web_acl" "waf" {
  count       = 3
  name        = "waf-${count.index + 1}"
  metric_name = "waf-${count.index + 1}"

  default_action {
    type = "ALLOW"
  }

  rules = [
    {
      priority = 1
      action = {
        type = "BLOCK"
      }
      override_action =  {
        type = "NONE"
      }
      rule_id = aws_waf_rule.rule[count.index].id
    }
  ]
}

# WAF 규칙 정의
resource "aws_waf_rule" "rule" {
  count = 3
  name  = "waf-rule-${count.index + 1}"

  metric_name = "waf-rule-${count.index + 1}"
  predicates = [
    {
      data_id = aws_waf_byte_match_set.set[count.index].id
      negated = false
      type    = "ByteMatch"
    }
  ]
}

