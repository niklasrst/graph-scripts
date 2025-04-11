$namespace = "root\cimv2\mdm\dmmap"
$className = "MDM_EnrollmentStatusTracking_Setup01"
 
if ($(Get-WmiObject -Class $className -Namespace $namespace).HasProvisioningCompleted -eq "True") {
    "Provisioning finished."
}else {
    "Provisioning not finished."
}