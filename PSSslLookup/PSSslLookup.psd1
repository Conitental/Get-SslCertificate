# Module manifest docs: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_module_manifests

@{

  RootModule = 'PSSslLookup.psm1'
  ModuleVersion = '1.0.0'
  GUID = '87f050f1-26eb-4a95-a5f6-abeeba2f9a7a'
  Author = 'Conitental'
  Description = 'Use the PSSslLookup module to retrieve presented ssl certificates from web servers.'

  FunctionsToExport = @(
    'Get-SslCertificate'
  )

}
