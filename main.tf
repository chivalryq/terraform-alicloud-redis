provider "alicloud" {
  profile                 = var.profile != "" ? var.profile : null
  shared_credentials_file = var.shared_credentials_file != "" ? var.shared_credentials_file : null
  region                  = var.region != "" ? var.region : null
  skip_region_validation  = var.skip_region_validation
  configuration_source    = "terraform-alicloud-modules/redis"
}

locals {
  vswitch_id = var.create_vswitch? module.vpc.this_vswitch_ids[0] : var.vswitch_id

}

data "alicloud_zones" "default" {
  available_resource_creation = "KVStore"
}

data "alicloud_kvstore_instance_classes" "default" {
  engine         = "Redis"
  engine_version = var.engine_version
  zone_id        = data.alicloud_zones.default.zones.0.id
}

module "redis" {
  source = "github.com/terraform-alicloud-modules/terraform-alicloud-redis"

  // Instance
  create_instance        = var.create_instance
  engine_version         = var.engine_version
  instance_name          = var.instance_name
  instance_class         = var.instance_class != "" ? var.instance_class : data.alicloud_kvstore_instance_classes.default.instance_classes.0
  availability_zone      = var.availability_zone
  vswitch_id             = local.vswitch_id
  security_ips           = var.security_ips
  instance_charge_type   = var.instance_charge_type
  period                 = var.period
  auto_renew             = var.auto_renew
  auto_renew_period      = var.auto_renew_period
  private_ip             = var.private_ip
  instance_backup_id     = var.instance_backup_id
  vpc_auth_mode          = var.vpc_auth_mode
  password               = var.password
  kms_encrypted_password = var.kms_encrypted_password
  kms_encryption_context = var.kms_encryption_context
  maintain_start_time    = var.maintain_start_time
  maintain_end_time      = var.maintain_end_time
  tags                   = var.tags

  // Backup Policy
  backup_policy_backup_period = var.backup_policy_backup_period
  backup_policy_backup_time   = var.backup_policy_backup_time

  // CMS Alarm
  enable_alarm_rule = var.enable_alarm_rule

  // Account
  accounts = var.accounts


}

module "vpc" {
  source             = "alibaba/vpc/alicloud"
  create             = true
  vpc_cidr           = "172.16.0.0/16"
  vswitch_cidrs      = ["172.16.0.0/21"]
  availability_zones = [data.alicloud_zones.default.zones.0.id]
}
