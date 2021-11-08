provider "alicloud" {
  profile                 = var.profile != "" ? var.profile : null
  shared_credentials_file = var.shared_credentials_file != "" ? var.shared_credentials_file : null
  region                  = var.region != "" ? var.region : null
  skip_region_validation  = var.skip_region_validation
  configuration_source    = "terraform-alicloud-modules/redis"
}

locals {
  this_instance_id      = var.existing_instance_id != "" ? var.existing_instance_id : concat(alicloud_kvstore_instance.this.*.id, [""])[0]
  create_more_resources = var.existing_instance_id != "" || var.create_instance ? true : false
  create_account        = local.create_more_resources && var.create_account
  project               = "acs_kvstore"
}

resource "alicloud_kvstore_instance" "this" {
  count                  = var.existing_instance_id != "" ? 0 : var.create_instance ? 1 : 0
  instance_type          = "Redis"
  instance_class         = var.instance_class
  instance_name          = var.instance_name
  password               = var.password
  kms_encrypted_password = var.kms_encrypted_password
  kms_encryption_context = var.kms_encryption_context
  engine_version         = var.engine_version
  vswitch_id             = var.vswitch_id
  security_ips           = var.security_ips
  instance_charge_type   = var.instance_charge_type
  availability_zone      = var.availability_zone
  period                 = var.period
  auto_renew             = var.auto_renew
  auto_renew_period      = var.auto_renew_period
  private_ip             = var.private_ip
  backup_id              = var.instance_backup_id
  tags                   = var.tags
  vpc_auth_mode          = var.vpc_auth_mode
  maintain_start_time    = var.maintain_start_time
  maintain_end_time      = var.maintain_end_time
}

resource "alicloud_kvstore_backup_policy" "this" {
  count         = local.create_more_resources ? 1 : 0
  instance_id   = local.this_instance_id
  backup_period = var.backup_policy_backup_period
  backup_time   = var.backup_policy_backup_time
}

module "accounts" {
  source                  = "./modules/account"
  redis_instance_id       = local.this_instance_id
  create_account          = local.create_account
  profile                 = var.profile
  shared_credentials_file = var.shared_credentials_file
  region                  = var.region
  skip_region_validation  = var.skip_region_validation
  accounts                = var.accounts
}

