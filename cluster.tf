resource "null_resource" "master" {
  for_each   = var.masters
  depends_on = [null_resource.master_firewall]

  triggers = {
    cluster_type          = var.type
    cluster_version       = var.rke_version
    cluster_channel       = var.channel
    cluster_disables      = jsonencode(var.disables)
    cluster_leader        = keys(var.masters)[0] == each.key
    cluster_load_balancer = coalesce(var.load_balancer, values(var.masters)[0].connection.host)
    cluster_master_token  = random_password.master_token.result
    cluster_worker_token  = random_password.worker_token.result
    cluster_registry      = var.registry
    node_name             = each.value.name
    node_labels           = jsonencode(each.value.labels)
    node_taints           = jsonencode(each.value.taints)
    connection            = jsonencode(each.value.connection)
  }
  connection {
    type                = try(jsondecode(self.triggers.connection).type, null)
    host                = try(jsondecode(self.triggers.connection).host, null)
    port                = try(jsondecode(self.triggers.connection).port, null)
    user                = try(jsondecode(self.triggers.connection).user, null)
    password            = try(jsondecode(self.triggers.connection).password, null)
    timeout             = try(jsondecode(self.triggers.connection).timeout, null)
    script_path         = try(jsondecode(self.triggers.connection).script_path, null)
    private_key         = try(jsondecode(self.triggers.connection).private_key, null)
    certificate         = try(jsondecode(self.triggers.connection).certificate, null)
    agent               = try(jsondecode(self.triggers.connection).agent, null)
    agent_identity      = try(jsondecode(self.triggers.connection).agent_identity, null)
    host_key            = try(jsondecode(self.triggers.connection).host_key, null)
    https               = try(jsondecode(self.triggers.connection).https, null)
    insecure            = try(jsondecode(self.triggers.connection).insecure, null)
    use_ntlm            = try(jsondecode(self.triggers.connection).use_ntlm, null)
    cacert              = try(jsondecode(self.triggers.connection).cacert, null)
    bastion_host        = try(jsondecode(self.triggers.connection).bastion_host, null)
    bastion_host_key    = try(jsondecode(self.triggers.connection).bastion_host_key, null)
    bastion_port        = try(jsondecode(self.triggers.connection).bastion_port, null)
    bastion_user        = try(jsondecode(self.triggers.connection).bastion_user, null)
    bastion_password    = try(jsondecode(self.triggers.connection).bastion_password, null)
    bastion_private_key = try(jsondecode(self.triggers.connection).bastion_private_key, null)
    bastion_certificate = try(jsondecode(self.triggers.connection).bastion_certificate, null)
  }

  provisioner "file" {
    when        = create
    destination = "/tmp/script.sh"
    content = templatefile("${path.module}/config/master.create.sh", {
      cluster_type          = self.triggers.cluster_type
      cluster_version       = self.triggers.cluster_version
      cluster_channel       = self.triggers.cluster_channel
      cluster_disables      = jsondecode(self.triggers.cluster_disables)
      cluster_leader        = self.triggers.cluster_leader
      cluster_load_balancer = self.triggers.cluster_load_balancer
      cluster_master_token  = self.triggers.cluster_master_token
      cluster_worker_token  = self.triggers.cluster_worker_token
      cluster_registry      = self.triggers.cluster_registry
      node_name             = self.triggers.node_name
      node_labels           = jsondecode(self.triggers.node_labels)
      node_taints           = jsondecode(self.triggers.node_taints)
    })
  }
  provisioner "remote-exec" {
    when = create
    inline = [
      "chmod +x /tmp/script.sh",
      "echo ${jsondecode(self.triggers.connection).password} | sudo -S /tmp/script.sh"
    ]
  }

  provisioner "file" {
    when        = destroy
    destination = "/tmp/script.sh"
    content = templatefile("${path.module}/config/master.destroy.sh", {
      cluster_type          = self.triggers.cluster_type
      cluster_version       = self.triggers.cluster_version
      cluster_channel       = self.triggers.cluster_channel
      cluster_disables      = jsondecode(self.triggers.cluster_disables)
      cluster_leader        = self.triggers.cluster_leader
      cluster_load_balancer = self.triggers.cluster_load_balancer
      cluster_master_token  = self.triggers.cluster_master_token
      cluster_worker_token  = self.triggers.cluster_worker_token
      cluster_registry      = self.triggers.cluster_registry
      node_name             = self.triggers.node_name
      node_labels           = jsondecode(self.triggers.node_labels)
      node_taints           = jsondecode(self.triggers.node_taints)
    })
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "chmod +x /tmp/script.sh",
      "echo ${jsondecode(self.triggers.connection).password} | sudo -S /tmp/script.sh"
    ]
  }
}

# resource "null_resource" "worker" {
#   for_each   = var.workers
#   depends_on = [null_resource.worker_firewall]

#   triggers = {
#     rke_type         = var.type
#     rke_version      = var.rke_version
#     rke_channel      = var.channel
#     rke_disable      = var.disable
#     rke_is_leader    = keys(var.masters)[0] == each.key
#     rke_loadbalancer = coalesce(var.loadbalancer, values(var.masters)[0].connection.host)
#     rke_master_token = random_password.master_secret.result
#     rke_worker_token = random_password.worker_secret.result
#     name             = each.value.name
#     labels           = jsonencode(each.value.labels)
#     taints           = jsonencode(each.value.taints)
#     connection       = jsonencode(each.value.connection)
#   }
#   connection {
#     type                = try(jsondecode(self.triggers.connection).type, null)
#     host                = try(jsondecode(self.triggers.connection).host, null)
#     port                = try(jsondecode(self.triggers.connection).port, null)
#     user                = try(jsondecode(self.triggers.connection).user, null)
#     password            = try(jsondecode(self.triggers.connection).password, null)
#     timeout             = try(jsondecode(self.triggers.connection).timeout, null)
#     script_path         = try(jsondecode(self.triggers.connection).script_path, null)
#     private_key         = try(jsondecode(self.triggers.connection).private_key, null)
#     certificate         = try(jsondecode(self.triggers.connection).certificate, null)
#     agent               = try(jsondecode(self.triggers.connection).agent, null)
#     agent_identity      = try(jsondecode(self.triggers.connection).agent_identity, null)
#     host_key            = try(jsondecode(self.triggers.connection).host_key, null)
#     https               = try(jsondecode(self.triggers.connection).https, null)
#     insecure            = try(jsondecode(self.triggers.connection).insecure, null)
#     use_ntlm            = try(jsondecode(self.triggers.connection).use_ntlm, null)
#     cacert              = try(jsondecode(self.triggers.connection).cacert, null)
#     bastion_host        = try(jsondecode(self.triggers.connection).bastion_host, null)
#     bastion_host_key    = try(jsondecode(self.triggers.connection).bastion_host_key, null)
#     bastion_port        = try(jsondecode(self.triggers.connection).bastion_port, null)
#     bastion_user        = try(jsondecode(self.triggers.connection).bastion_user, null)
#     bastion_password    = try(jsondecode(self.triggers.connection).bastion_password, null)
#     bastion_private_key = try(jsondecode(self.triggers.connection).bastion_private_key, null)
#     bastion_certificate = try(jsondecode(self.triggers.connection).bastion_certificate, null)
#   }

#   provisioner "file" {
#     when        = create
#     destination = "/tmp/script.sh"
#     content = templatefile("${path.module}/config/worker.create.sh", {
#       rke_type         = self.triggers.rke_type
#       rke_version      = self.triggers.rke_version
#       rke_channel      = self.triggers.rke_channel
#       rke_disable      = self.triggers.rke_disable
#       rke_is_leader    = self.triggers.rke_is_leader
#       rke_loadbalancer = self.triggers.rke_loadbalancer
#       rke_master_token = self.triggers.rke_master_token
#       rke_worker_token = self.triggers.rke_worker_token
#       node_name        = self.triggers.name
#       node_labels      = jsondecode(self.triggers.labels)
#       node_taints      = jsondecode(self.triggers.taints)
#     })
#   }
#   provisioner "remote-exec" {
#     when = create
#     inline = [
#       "chmod +x /tmp/script.sh",
#       "echo ${jsondecode(self.triggers.connection).password} | sudo -S /tmp/script.sh"
#     ]
#   }

#   provisioner "file" {
#     when        = destroy
#     destination = "/tmp/script.sh"
#     content = templatefile("${path.module}/config/worker.destroy.sh", {
#       rke_type         = self.triggers.rke_type
#       rke_version      = self.triggers.rke_version
#       rke_channel      = self.triggers.rke_channel
#       rke_disable      = self.triggers.rke_disable
#       rke_is_leader    = self.triggers.rke_is_leader
#       rke_loadbalancer = self.triggers.rke_loadbalancer
#       rke_master_token = self.triggers.rke_master_token
#       rke_worker_token = self.triggers.rke_worker_token
#       node_name        = self.triggers.name
#       node_labels      = jsondecode(self.triggers.labels)
#       node_taints      = jsondecode(self.triggers.taints)
#     })
#   }
#   provisioner "remote-exec" {
#     when = destroy
#     inline = [
#       "chmod +x /tmp/script.sh",
#       "echo ${jsondecode(self.triggers.connection).password} | sudo -S /tmp/script.sh"
#     ]
#   }
# }
