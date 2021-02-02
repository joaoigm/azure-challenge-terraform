resource "azurerm_cdn_profile" "main" {
	
	name = "${var.project_name}-cdn"
	resource_group_name = azurerm_resource_group.main.name
	location = azurerm_resource_group.main.location

	sku = "Standard_Microsoft" 
}

resource "azurerm_storage_account" "main" {
	
  name = "${var.project_name}stg"
  resource_group_name = azurerm_resource_group.main.name
	location = azurerm_resource_group.main.location

	account_kind = "StorageV2"
	account_tier = "Standard"

	account_replication_type = "LRS"

	static_website {
		index_document = "index.html"
	}
}

resource "azurerm_cdn_endpoint" "main" {
	
	name = "${var.project_name}cdnendpoint"
	location = azurerm_resource_group.main.location
	resource_group_name = azurerm_resource_group.main.name

	profile_name = azurerm_cdn_profile.main.name

	

	is_http_allowed = true
	is_https_allowed = true

	origin_host_header = replace(azurerm_storage_account.main.primary_web_host, "/", "")

	origin {
		name = "${var.project_name}cdnendpointorigin"
		host_name = replace(azurerm_storage_account.main.primary_web_host, "/", "")
		http_port = 80
		https_port = 443
	}

}


resource "azurerm_web_application_firewall_policy" "cdn-main" {
	
  name                = "${var.project_name}_cdnwaf"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.1"
    }
  }

}