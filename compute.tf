# Create a random resource
resource "random_id" "mtc_node_id" {
    byte_length = 2
    count = var.main_instance_count
}

# Create AMI data source
data "aws_ami" "server_ami" {
    most_recent = true
    owners      = ["099720109477"] # Canonical

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
}


# Create a key pair
resource "aws_key_pair" "mtc_terransible_auth" {
    key_name   = var.key_name
    public_key = "${file(var.public_key)}"
}

# Create an instance
resource "aws_instance" "mtc_terransible_node" {
    count = var.main_instance_count
    instance_type          = var.main_instance_type
    ami                    = data.aws_ami.server_ami.id
    key_name               = aws_key_pair.mtc_terransible_auth.id
    vpc_security_group_ids = [aws_security_group.mtc_terransible_sg.id]
    subnet_id              = aws_subnet.mtc_terransible_pub_subnet.*.id[count.index]
    #user_data              = file("userdata.tpl")

    root_block_device {
        volume_size = var.main_volume_size
    }
    tags = {
        name = "mtc-terransible-main-${random_id.mtc_node_id[count.index].dec}"
    }

    # Provisioner(s) are a last resort. You will want to avoid using them as mush as possible.
    #provisioner "local-exec" {
    #    command = templatefile("${var.host_os}-ssh-config.tpl", {
    #    hostname     = self.public_ip,
    #    user         = "ubuntu",
    #    identityfile = "~/.ssh/mtc-terransiblekey",
    #    })

    #interpreter = var.host_os == "windows" ? ["powershell", "-command"] : ["bash", "-c"] # For windows users
    #}
}