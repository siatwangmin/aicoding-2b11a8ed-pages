$ErrorActionPreference = 'Stop'
$tokenFile = Join-Path $env:TEMP 'gh-token.txt'
$t = (Get-Content $tokenFile -Raw).Trim()

$body = '{"name":"aicoding-2b11a8ed-pages","description":"Static prototype showcase for aicoding-2b11a8ed","private":false,"auto_init":false}'
$tmpBody = Join-Path $env:TEMP 'repo-body.json'
Set-Content -Path $tmpBody -Value $body -Encoding ASCII

$raw = curl.exe -s --retry 3 --retry-delay 2 --retry-all-errors -X POST -H "Authorization: token $t" -H "Accept: application/vnd.github+json" https://api.github.com/user/repos -d "@$tmpBody"
if (-not $raw) { Write-Output "EMPTY_RESPONSE"; exit 1 }
$resp = $raw | ConvertFrom-Json
if ($resp.full_name) {
  Write-Output "CREATED: $($resp.full_name) -> $($resp.html_url)"
} elseif ($resp.message -match 'already exists') {
  Write-Output "ALREADY_EXISTS"
} else {
  $head = ($raw -join ' ')
  if ($head.Length -gt 400) { $head = $head.Substring(0, 400) }
  Write-Output "CREATE_MSG: $head"
}
