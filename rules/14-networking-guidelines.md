# RouterOS and Networking Guidelines

Comprehensive standards for RouterOS v7 scripting, network automation, and system management.

## RouterOS Scripting Conventions

### Script Structure Standards
```rsc
# Script Name: DNS Updater
# @author Network Admin
# @created 2025-01-15 10:30:00
# @description Dynamic DNS updater for Cloudflare
# @version 1.2.0
# @dependencies RouterOS 7.12+, cloudflare-api

# Global configuration
:global dnsEnabled true
:global dnsDomain "example.com"
:global dnsRecordId "12345"
:global lastKnownIp ""
:global updateTimestamp

# Debug configuration
:global debugEnabled false

# Constants
:local apiUrl "https://api.cloudflare.com/client/v4/zones"
:local checkInterval "5m"
:local maxRetries 3
:local retryDelay "30s"
```

### Variable Conventions
```rsc
# Local variables (script scope only)
:local currentIpAddress "0.0.0.0"
:local apiAccessKey "your-key"
:local targetDomain "example.com"
:local interfaceName "ether1"

# Global variables (persistent across runs)
:global lastKnownIp
:global updateTimestamp
:global failedAttempts
:global lastSyncTime

# Configuration variables
:local config {
    "enabled": true,
    "domain": "example.com",
    "ttl": 300,
    "proxy": false
}
```

### Control Flow Patterns
```rsc
# Simple condition with descriptive variable names
:if ($interfaceIsActive) do={
    :log info "Interface is operational"
}

# Complex conditions with logical grouping
:if (($currentIp != "") && ($currentIp != $previousIp) && ($recordId != "")) do={
    :log info "All conditions met for DNS update"
    # Execute update logic
}

# Multi-branch logic with early returns
:if ($apiResponse = "") do={
    :log error "API response is empty"
    :return
} else={
    :if ([:find $apiResponse "error"] != "") do={
        :log error "API returned error: $apiResponse"
        :return
    } else={
        :log info "API call successful"
        # Process successful response
    }
}
```

## API Integration Standards

### HTTP Request Patterns
```rsc
# GET request with error handling
:local apiGet do={
    :local url $1
    :local headers $2
    :local result ""

    :do {
        :set result [/tool fetch url=$url http-header-field=$headers as-value output=user]->"data"
        :log info "API GET successful: $url"
    } on-error={
        :log error "API GET failed: $url"
        :return ""
    }

    :return $result
}

# POST with JSON payload and authentication
:local apiPost do={
    :local url $1
    :local payload $2
    :local apiKey $3

    :local jsonPayload $payload
    :local authHeader "Authorization: Bearer $apiKey"
    :local contentHeader "Content-Type: application/json"

    :local postResult [/tool fetch url=$url as-value output=user \
        http-method=post \
        http-header-field=$authHeader \
        http-header-field=$contentHeader \
        http-data=$jsonPayload]->"data"]

    :return $postResult
}
```

### JSON Response Processing
```rsc
# Function to extract JSON string value by key
:local extractJsonValue do={
    :local jsonData $1
    :local keyName $2

    :local keyStart [:find $jsonData "\"$keyName\""]
    :if ($keyStart = "") do={
        :log warning "JSON key '$keyName' not found"
        :return ""
    }

    :local valueSection [:pick $jsonData $keyStart [:len $jsonData]]
    :local colonPos [:find $valueSection ":"]
    :local quoteStart [:find [:pick $valueSection $colonPos [:len $valueSection]] "\""]

    :if ($quoteStart != "") do={
        :local valueStart ($colonPos + $quoteStart + 1)
        :local valueEnd [:find [:pick $valueSection $valueStart [:len $valueSection]] "\""]
        :if ($valueEnd != "") do={
            :local extractedValue [:pick $valueSection $valueStart ($valueStart + $valueEnd)]
            :log debug "Extracted '$keyName': $extractedValue"
            :return $extractedValue
        }
    }

    :log error "Failed to parse JSON value for key '$keyName'"
    :return ""
}

# Usage example
:local ipAddress [$extractJsonValue $apiResponse "ip"]
:local recordId [$extractJsonValue $apiResponse "record_id"]
:local success [$extractJsonValue $apiResponse "success"]
```

## Network Operations

### Interface Management
```rsc
# Function to get clean IP address from interface
:local getInterfaceIp do={
    :local interfaceName $1

    # Validate interface exists
    :if ([:len [/interface find name=$interfaceName]] = 0) do={
        :log error "Interface '$interfaceName' not found"
        :return ""
    }

    # Check if interface has IP address
    :local addressId [/ip address find interface=$interfaceName]
    :if ([:len $addressId] = 0) do={
        :log warning "No IP address found on interface '$interfaceName'"
        :return ""
    }

    # Extract IP without subnet mask
    :local fullAddress [/ip address get $addressId address]
    :local slashPos [:find $fullAddress "/"]
    :if ($slashPos != "") do={
        :local cleanIp [:pick $fullAddress 0 $slashPos]
        :log debug "Interface '$interfaceName' IP: $cleanIp"
        :return $cleanIp
    }

    :return $fullAddress
}

# Function to check interface operational status
:local checkInterfaceStatus do={
    :local interfaceName $1

    :local interfaceRunning [/interface get [/interface find name=$interfaceName] running]
    :local interfaceDisabled [/interface get [/interface find name=$interfaceName] disabled]

    :if ($interfaceDisabled = true) do={
        :log warning "Interface '$interfaceName' is disabled"
        :return false
    }

    :if ($interfaceRunning = true) do={
        :log info "Interface '$interfaceName' is operational"
        :return true
    } else={
        :log error "Interface '$interfaceName' is down"
        :return false
    }
}
```

### Routing and Gateway Management
```rsc
# Function to add static route
:local addStaticRoute do={
    :local destination $1
    :local gateway $2
    :local distance $3
    :local comment $4

    :if ([:len [/ip route find dst-address=$destination gateway=$gateway]] > 0) do={
        :log warning "Route already exists: $destination via $gateway"
        :return false
    }

    :local routeId [/ip route add dst-address=$destination gateway=$gateway distance=$distance comment=$comment]
    :if ($routeId != "") do={
        :log info "Added static route: $destination via $gateway (distance: $distance)"
        :return true
    } else={
        :log error "Failed to add static route: $destination via $gateway"
        :return false
    }
}

# Function to monitor gateway connectivity
:local monitorGateway do={
    :local gateway $1
    :local checkInterval $2
    :local failureThreshold $3

    :local failureCount 0

    :while (true) do={
        :local pingResult [/ping $gateway count=3 interval=1s]

        :if ($pingResult > 0) do={
            :if ($failureCount > 0) do={
                :log info "Gateway $gateway is back online"
            }
            :set failureCount 0
        } else={
            :set failureCount ($failureCount + 1)
            :log warning "Gateway $gateway ping failed (attempt $failureCount/$failureThreshold)"

            :if ($failureCount >= $failureThreshold) do={
                :log error "Gateway $gateway appears to be down after $failureThreshold failures"
                # Implement failover logic here
            }
        }

        :delay $checkInterval
    }
}
```

## String Processing Utilities

### String Helper Functions
```rsc
# Function to validate string is not empty
:local isValidString do={
    :local inputString $1
    :return (($inputString != "") && ($inputString != nil))
}

# Function to safely extract substring
:local safeSubstring do={
    :local sourceString $1
    :local startPos $2
    :local endPos $3

    :local stringLength [:len $sourceString]
    :if ($startPos >= $stringLength) do={
        :return ""
    }

    :if ($endPos > $stringLength) do={
        :set endPos $stringLength
    }

    :return [:pick $sourceString $startPos $endPos]
}

# Function to split string by delimiter
:local splitString do={
    :local inputString $1
    :local delimiter $2
    :local resultArray [:toarray ""]

    :local currentPos 0
    :local delimiterPos [:find $inputString $delimiter]

    :while ($delimiterPos != "") do={
        :local part [:pick $inputString $currentPos $delimiterPos]
        :set resultArray ($resultArray, $part)
        :set currentPos ($delimiterPos + [:len $delimiter])
        :set delimiterPos [:find $inputString $delimiter $currentPos]
    }

    # Add remaining part
    :local finalPart [:pick $inputString $currentPos [:len $inputString]]
    :set resultArray ($resultArray, $finalPart)

    :return $resultArray
}

# Function to trim whitespace
:local trimString do={
    :local inputString $1

    # Remove leading whitespace
    :while (([:len $inputString] > 0) && ([:pick $inputString 0 1] = " ")) do={
        :set inputString [:pick $inputString 1 [:len $inputString]]
    }

    # Remove trailing whitespace
    :while (([:len $inputString] > 0) && ([:pick $inputString ([:len $inputString] - 1) [:len $inputString]] = " ")) do={
        :set inputString [:pick $inputString 0 ([:len $inputString] - 1)]
    }

    :return $inputString
}
```

## Logging and Monitoring

### Structured Logging
```rsc
# Global debug flag for development
:global debugEnabled false

# Logging function with context
:local logWithContext do={
    :local level $1
    :local context $2
    :local message $3
    :local timestamp [/system clock get time]

    :log $level "[$timestamp][$context] $message"
}

# Usage examples with proper context
[$logWithContext "info" "DNS_UPDATE" "Starting DNS record update process"]
[$logWithContext "debug" "API_CALL" "Sending request to: $apiEndpoint"]
[$logWithContext "warning" "VALIDATION" "IP address format validation failed: $ipAddress"]
[$logWithContext "error" "NETWORK" "Interface $interfaceName is not responding"]

# Conditional debug logging
:if ($debugEnabled = true) do={
    [$logWithContext "debug" "VARIABLES" "currentIp=$currentIp, previousIp=$previousIp"]
    [$logWithContext "debug" "API_RESPONSE" "Raw response: $apiResponse"]
}
```

### Performance Monitoring
```rsc
# Function to monitor script performance
:local performanceMonitor do={
    :local operationName $1
    :local startTime [/system clock get time]

    # Store start time for later calculation
    :global ("perfStart" . $operationName) $startTime
    [$logWithContext "debug" "PERFORMANCE" "Started operation: $operationName"]
}

:local performanceEnd do={
    :local operationName $1
    :local endTime [/system clock get time]

    :global ("perfStart" . $operationName)
    :local startTime $("perfStart" . $operationName)

    :if ($startTime != "") do={
        :local duration ($endTime - $startTime)
        [$logWithContext "info" "PERFORMANCE" "Completed operation: $operationName (duration: ${duration}s)"]
    } else={
        [$logWithContext "warning" "PERFORMANCE" "No start time found for operation: $operationName"]
    }

    # Clean up performance tracking variable
    :set ("perfStart" . $operationName) nil
}
```

## Security Best Practices

### Credential Management
```rsc
# Function to securely retrieve credentials
:local getCredential do={
    :local credentialName $1

    # Try to get from global variables first
    :global ("stored" . $credentialName)
    :local credentialValue $("stored" . $credentialName)

    :if (![$isValidString $credentialValue]) do={
        [$logWithContext "error" "SECURITY" "Credential '$credentialName' not found"]
        :return ""
    }

    [$logWithContext "debug" "SECURITY" "Retrieved credential: $credentialName"]
    :return $credentialValue
}

# Input sanitization function
:local sanitizeInput do={
    :local inputValue $1
    :local allowedChars $2

    # Remove potentially dangerous characters
    :local sanitized $inputValue
    :local dangerousChars [";", "&", "|", "`", "\$", "(", ")", "{", "}"]

    :foreach char in=$dangerousChars do={
        :set sanitized [:tostr [:find $sanitized $char ""]]
    }

    :if ($sanitized != $inputValue) do={
        [$logWithContext "warning" "SECURITY" "Input sanitized: potentially dangerous characters removed"]
    }

    :return $sanitized
}

# Network validation
:local validateNetworkAccess do={
    :local targetHost $1

    # Test connectivity before API calls
    :local pingResult [/ping $targetHost count=1]
    :if ($pingResult = 0) do={
        [$logWithContext "error" "NETWORK" "Cannot reach target host: $targetHost"]
        :return false
    }

    :return true
}
```

## Automation and Scheduling

### Scheduler Management
```rsc
# Function to create or update scheduler
:local createScheduler do={
    :local schedulerName $1
    :local interval $2
    :local scriptName $3
    :local startTime $4

    # Remove existing scheduler if present
    :if ([:len [/system scheduler find name=$schedulerName]] > 0) do={
        /system scheduler remove [find name=$schedulerName]
        [$logWithContext "info" "SCHEDULER" "Removed existing scheduler: $schedulerName"]
    }

    # Create new scheduler
    /system scheduler add \
        name=$schedulerName \
        interval=$interval \
        start-time=$startTime \
        on-event="/system script run $scriptName"

    [$logWithContext "info" "SCHEDULER" "Created scheduler: $schedulerName (interval: $interval)"]
}

# Time-based execution control
:local isExecutionTimeValid do={
    :local startHour $1
    :local endHour $2

    :local currentTime [/system clock get time]
    :local currentHour [:tonum [:pick $currentTime 0 2]]

    :if (($currentHour >= $startHour) && ($currentHour <= $endHour)) do={
        [$logWithContext "info" "SCHEDULE" "Execution time valid (hour: $currentHour)"]
        :return true
    } else={
        [$logWithContext "info" "SCHEDULE" "Outside execution window (hour: $currentHour)"]
        :return false
    }
}
```

### Error Handling with Retry
```rsc
# Error handling with recovery
:local executeWithRetry do={
    :local operation $1
    :local maxRetries $2
    :local retryDelay $3

    :local attempt 0
    :while ($attempt < $maxRetries) do={
        :do {
            [$operation]
            [$logWithContext "info" "RETRY" "Operation succeeded on attempt $($attempt + 1)"]
            :return true
        } on-error={
            :set attempt ($attempt + 1)
            :if ($attempt < $maxRetries) do={
                [$logWithContext "warning" "RETRY" "Attempt $attempt failed, retrying in $retryDelay seconds"]
                :delay $retryDelay
            } else={
                [$logWithContext "error" "RETRY" "All $maxRetries attempts failed"]
                :return false
            }
        }
    }
}
```

## Firewall Management

### Address List Management
```rsc
# Address list management with validation
:local manageAddressList do={
    :local listName $1
    :local action $2
    :local targetAddress $3
    :local comment $4

    :if ($action = "clear") do={
        :local existingEntries [/ip firewall address-list find list=$listName]
        :if ([:len $existingEntries] > 0) do={
            /ip firewall address-list remove $existingEntries
            [$logWithContext "info" "FIREWALL" "Cleared address list: $listName"]
        }
    }

    :if ($action = "add") do={
        # Validate IP address
        :if ([:len [:toip $targetAddress]] = 0) do={
            [$logWithContext "error" "FIREWALL" "Invalid IP address: $targetAddress"]
            :return false
        }

        # Check if address already exists
        :if ([:len [/ip firewall address-list find list=$listName address=$targetAddress]] > 0) do={
            [$logWithContext "warning" "FIREWALL" "Address already in list: $targetAddress"]
            :return true
        }

        /ip firewall address-list add list=$listName address=$targetAddress comment=$comment
        [$logWithContext "info" "FIREWALL" "Added to $listName: $targetAddress"]
    }

    :return true
}
```

### Rule Management
```rsc
# Function to add firewall rule with validation
:local addFirewallRule do={
    :local chain $1
    :local srcAddress $2
    :local dstPort $3
    :local action $4
    :local comment $5

    # Validate parameters
    :if ($chain = "" || $action = "") do={
        [$logWithContext "error" "FIREWALL" "Chain and action are required"]
        :return false
    }

    # Check if rule already exists
    :local existingRules [/ip firewall filter find chain=$chain src-address=$srcAddress dst-port=$dstPort action=$action]
    :if ([:len $existingRules] > 0) do={
        [$logWithContext "warning" "FIREWALL" "Firewall rule already exists"]
        :return true
    }

    # Add new rule
    :local ruleId [/ip firewall filter add chain=$chain src-address=$srcAddress dst-port=$dstPort action=$action comment=$comment]
    :if ($ruleId != "") do={
        [$logWithContext "info" "FIREWALL" "Added firewall rule: $chain $srcAddress:$dstPort -> $action"]
        :return true
    } else={
        [$logWithContext "error" "FIREWALL" "Failed to add firewall rule"]
        :return false
    }
}
```