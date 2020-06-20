project_prefix =  "test-carlesaks"
project_sufix = "ne-001"
project_location    = "northeurope"
project_tags = {
    "Owner": "https://twitter.com/carlesanagustin"
    "Environment": "dev"
    "Service": "AKS"
    "Version": "001"
    }

office_pip = [""]
k8s_ingress_ip = ["10.1.16.5"]

k8s_version = "1.16.9"
k8s_vm_size = "Standard_D2_v3"
k8s_npool_min_count = 1
k8s_npool_max_count = 3
k8s_npool_node_count = 1
k8s_npool_scale = true
k8s_disk_gb = 30

auto_scaler_settings = {
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