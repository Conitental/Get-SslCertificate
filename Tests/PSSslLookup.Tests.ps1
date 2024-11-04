#Requires -Modules PSScriptAnalyzer

BeforeAll {
	$ModuleRoot = "$PSScriptRoot\..\PSSslLookup\"

	Import-Module "$ModuleRoot\PSSslLookup.psm1"

	# Additionally dot source the private scripts to expose them to testing
	@(Get-ChildItem $ModuleRoot\Private\*.ps1) | Foreach-Object { . $_.FullName }
}

Describe "PSScriptAnalyzer" {
	It "should show no warnings or errors." {
		$Results = Invoke-ScriptAnalyzer -Path $ModuleRoot -Recurse
		$Results | Out-String | Write-Host
		$Results | Should -Be $null
	}
}

Describe "Get-SslCertificate" {
	It "should show github's canonical name" {
		Get-SslCertificate -Uri 'github.com' | Select-Object -ExpandProperty Subject | Should -Be 'CN=github.com'
	}

	It "should return a pscustomobject" {
		Get-SslCertificate -Uri 'github.com' | Should -BeOfType System.Object
	}
}
