resource "aws_iam_role" "client_role" {
  name               = "client-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# SSM managed instance core
resource "aws_iam_role_policy_attachment" "ssm_agent" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  role       = aws_iam_role.client_role.name
}

# Full access S3 bucket
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.client_role.name
}

resource "aws_iam_instance_profile" "client_profile" {
  name = "training-profile"
  role = aws_iam_role.client_role.name
}

# VMs
module "vm" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "~> 4.5.0"
  for_each                    = toset(var.vm_names)
  name                        = each.key
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_default_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.client.id]
  iam_instance_profile        = aws_iam_instance_profile.client_profile.name
  user_data_base64            = data.template_cloudinit_config.client_cloud_init[each.key].rendered
  key_name                    = aws_key_pair.generated_key[each.key].key_name
  monitoring                  = true
  associate_public_ip_address = true
  root_block_device = [
    {
      volume_size = 100 # in GB <<----- I increased this!
      volume_type = "gp3"
    }
  ]
  tags = var.tags
}
