variable "k8s_sp_client_id" {
   default = ""
}
variable "k8s_sp_client_secret" {
   default = ""
}

variable "k8s_version" {
  default = "1.16.9"
}
variable "k8s_vm_size" {
  default = "Standard_D2_v3"
}
variable "k8s_npool_min_count" {
  default = 1
}
variable "k8s_npool_max_count" {
  default = 3
}
variable "k8s_npool_node_count" {
  default = 1
}
variable "k8s_npool_scale" {
  default = true
}
variable "k8s_disk_gb" {
  default = 30
}

variable "auto_scaler_settings" {
  description = "auto scaler settings"
  default     = {
    balance_similar_node_groups      = false
    max_graceful_termination_sec     = 600
    scan_interval                    = "10s"
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_delay_after_failure   = "3m"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = 0.5
  }
}

