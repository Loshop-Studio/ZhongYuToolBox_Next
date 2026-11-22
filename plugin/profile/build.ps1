$ErrorActionPreference = 'Stop'

$DartEvalVersion = '0.8.5'
$Root = $PSScriptRoot
$BindingsDir = Join-Path $Root '.dart_eval\bindings'
$BindingsFile = Join-Path $BindingsDir 'flutter_eval.json'
$ExampleBindingsFile = Join-Path $Root '..\example\.dart_eval\bindings\flutter_eval.json'
$BuildDir = Join-Path $Root 'build\package'
$DistDir = Join-Path $Root 'dist'
$PluginId = 'com.zhongyu.toolbox.profile'
$PluginDir = Join-Path $DistDir $PluginId
$ZipFile = Join-Path $BuildDir 'profile.zip'
$PluginFile = Join-Path $PluginDir "$PluginId.zytbplugin"
$IndexFile = Join-Path $DistDir 'index.txt'

Push-Location $Root
try {
  flutter pub get
  if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed' }

  New-Item -ItemType Directory -Force -Path $BindingsDir | Out-Null
  if (Test-Path -LiteralPath $ExampleBindingsFile) {
    Copy-Item -LiteralPath $ExampleBindingsFile -Destination $BindingsFile -Force
  } elseif (-not (Test-Path -LiteralPath $BindingsFile)) {
    curl.exe --fail --location --retry 3 `
      --header 'Accept: application/octet-stream' `
      --header 'X-GitHub-Api-Version: 2022-11-28' `
      --output $BindingsFile `
      'https://api.github.com/repos/ethanblake4/flutter_eval/releases/assets/341897071'
    if ($LASTEXITCODE -ne 0) { throw 'flutter_eval bindings download failed' }
  }

  dart pub global activate dart_eval $DartEvalVersion
  if ($LASTEXITCODE -ne 0) { throw 'dart_eval activation failed' }

  if (Test-Path -LiteralPath $BuildDir) {
    Remove-Item -LiteralPath $BuildDir -Recurse -Force
  }
  New-Item -ItemType Directory -Force -Path $BuildDir, $PluginDir | Out-Null
  dart pub global run dart_eval:dart_eval compile -o (Join-Path $BuildDir 'plugin.evc')
  if ($LASTEXITCODE -ne 0) { throw 'dart_eval compile failed' }
  Copy-Item -LiteralPath (Join-Path $Root 'manifest.json') -Destination $BuildDir

  if (Test-Path -LiteralPath $PluginFile) {
    Remove-Item -LiteralPath $PluginFile -Force
  }
  Compress-Archive -Path (Join-Path $BuildDir '*') -DestinationPath $ZipFile
  Move-Item -LiteralPath $ZipFile -Destination $PluginFile
  [System.IO.File]::WriteAllText(
    $IndexFile,
    "(com.zhongyu.toolbox.profile@1.0.8)[个人信息]查看和编辑当前账号个人资料。`n",
    [System.Text.UTF8Encoding]::new($false)
  )
  Write-Host "Built: $PluginFile"
  Write-Host "Index: $IndexFile"
} finally {
  Pop-Location
}
