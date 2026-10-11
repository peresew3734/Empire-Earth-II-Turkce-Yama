<#
    Ee2Yama.ps1 - Empire Earth II / Empire Earth II Gold Edition
    Turkce yama motoru. Oyunun zips/db*.zip dosyalari icindeki db/Text/*.utf8
    metin dosyalarina, anahtar bazinda Turkce deger yazar.

    Kullanim:
      powershell -ExecutionPolicy Bypass -File Ee2Yama.ps1 -Mode Install -GameDir "<yol>" -Ceviriler "<ceviriler.txt>"
      powershell -ExecutionPolicy Bypass -File Ee2Yama.ps1 -Mode Undo   -GameDir "<yol>"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][ValidateSet('Install', 'Undo', 'Check')][string] $Mode,
    [string] $GameDir,
    [string] $Ceviriler,
    [string] $LanguageTable,
    [string] $Language = 'Turkish',
    [ValidateSet('Turkce', 'Ascii')][string] $Kodlama = 'Turkce'
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

# ---------------------------------------------------------------- k yardimci
function Write-Step { param($m) Write-Host "==> $m" -ForegroundColor Cyan }
function Write-Ok   { param($m) Write-Host "    [OK] $m" -ForegroundColor Green }
function Write-Warn2{ param($m) Write-Host "    [!]  $m" -ForegroundColor Yellow }
function Write-Err  { param($m) Write-Host "    [X]  $m" -ForegroundColor Red }

# Oyun klasorunu otomatik bul
function Find-GameDir {
    if ($GameDir -and (Test-Path (Join-Path $GameDir 'EE2.exe'))) {
        return (Resolve-Path $GameDir).Path
    }
    # 1) kayitli Steam kutuphaneleri
    $steamRoots = @()
    foreach ($k in @('HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam')) {
        if (Test-Path $k) {
            $p = (Get-ItemProperty $k -ErrorAction SilentlyContinue).SteamPath
            if ($p) { $steamRoots += $p }
        }
    }
    foreach ($d in 'C', 'D', 'E', 'F') { $steamRoots += "${d}:\SteamLibrary\steamapps\common"; $steamRoots += "${d}:\Steam\steamapps\common" }
    foreach ($r in $steamRoots) {
        $cand = Join-Path $r 'Empire Earth II Gold Edition'
        if (Test-Path (Join-Path $cand 'EE2.exe')) { return (Resolve-Path $cand).Path }
    }
    throw "Oyun klasörü bulunamadı. -GameDir ile elle verin."
}

# ------------------------------------------------------- CSV alan ayristirma
# Metin dosyalari:  KEY,"""DEGER"""
# OYUNUN KACIS DIZILERI (\" , \\ , \n , %VAR% , <etiket>) BOZULMAMALIDIR.
# Bu yuzden deger COZULMEZ; yalnizca dis """""" ayirlanip ham icerik aynen korunur.
function Split-TextLine {
    param([string] $Line)
    $i = $Line.IndexOf(',')
    if ($i -lt 0) { return $null }
    $key = $Line.Substring(0, $i)
    $rest = $Line.Substring($i + 1)
    $t = $rest -replace '^[ \t]+', ''
    if (-not $t.StartsWith('"""')) { return $null }
    $end = $t.LastIndexOf('"""')
    if ($end -lt 3) { return $null }
    if (($t.Substring($end + 3)) -replace '[\s]', '') { return $null }   # kapanistan sonra bir sey olmamali
    $val = $t.Substring(3, $end - 3)
    return [PSCustomObject]@{ Key = $key; Value = $val }
}

function Format-TextLine {
    param([string] $Key, [string] $Value)
    return ($Key + ',"""' + $Value + '"""')
}

# UTF-8 BOM'suz yaz
function Write-Utf8NoBom {
    param([string] $Path, [string] $Text)
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $enc)
}

# --------------------------------------------------------- ceviri tablosu
# Turkce karakterleri ASCII'ye indirger (font desteklemiyorsa kullanilir)
function Convert-ToAscii {
    param([string] $s)
    $map = @{
        [char]0x00E7 = 'c'; [char]0x00C7 = 'C'   # c C
        [char]0x011F = 'g'; [char]0x011E = 'G'   # g G
        [char]0x0131 = 'i'; [char]0x0130 = 'I'   # i I
        [char]0x00F6 = 'o'; [char]0x00D6 = 'O'   # o O
        [char]0x015F = 's'; [char]0x015E = 'S'   # s S
        [char]0x00FC = 'u'; [char]0x00DC = 'U'   # u U
        [char]0x00E2 = 'a'; [char]0x00C2 = 'A'   # a A
        [char]0x00EE = 'i'; [char]0x00CE = 'I'   # i I
        [char]0x00FB = 'u'; [char]0x00DB = 'U'   # u U
        [char]0x2019 = "'"; [char]0x201C = [char]0x201E; [char]0x201D = [char]0x201E
    }
    $sb = New-Object System.Text.StringBuilder
    foreach ($ch in $s.ToCharArray()) {
        if ($map.ContainsKey($ch)) { [void]$sb.Append($map[$ch]) } else { [void]$sb.Append($ch) }
    }
    return $sb.ToString()
}

function Read-Ceviriler {
    param([string] $Path)
    if (-not (Test-Path $Path)) { throw "Ceviri dosyasi bulunamadi: $Path" }
    $map = @{}
    $dupe = 0
    foreach ($line in [System.IO.File]::ReadAllLines($Path, [System.Text.Encoding]::UTF8)) {
        if ($line.Length -eq 0) { continue }
        if ($line.StartsWith('#')) { continue }
        $t = $line.IndexOf("`t")
        if ($t -lt 0) { continue }
        $k = $line.Substring(0, $t)
        $v = $line.Substring($t + 1)
        # DIKKAT: deger ham olarak kullanilir; \n \t \" \\ gibi kacis dizileri OYUNDA cozulur,
        # burada dokunulmaz.
        if ($map.ContainsKey($k)) {
            if ($map[$k] -ne $v) { $dupe++ ; Write-Warn2 "Çakışan anahtar (farklı değer): $k" }
            continue
        }
        $map[$k] = $v
    }
    Write-Ok "Çeviri tablosu: $($map.Count) anahtar"
    if ($dupe -gt 0) { Write-Warn2 "$dupe çakışan anahtar atlandı" }
    return $map
}

# ------------------------------------------------------------ zip isleme
function Convert-TextEntry {
    param([string] $Text, $Map, [ref] $HitRef, [ref] $MissRef, [ref] $KeptRef)
    $nl = if ($Text.Contains("`r`n")) { "`r`n" } else { "`n" }
    $lines = $Text -split "`r`n|`n"
    $res = New-Object System.Collections.Generic.List[string]
    $hits = 0; $miss = 0
    for ($n = 0; $n -lt $lines.Count; $n++) {
        $line = $lines[$n]
        $trim = $line.Trim()
        if ($trim.Length -eq 0 -or $trim.StartsWith('//')) {
            $res.Add($line); continue
        }
        $p = Split-TextLine $line
        if ($null -eq $p) {
            $res.Add($line); continue
        }
        if ($Map.ContainsKey($p.Key.Trim())) {
            $res.Add((Format-TextLine $p.Key $Map[$p.Key.Trim()]))
            $hits++
        }
        else {
            $res.Add($line)
            $miss++
            if ($null -ne $KeptRef.Value) { $KeptRef.Value.Add("$($p.Key)`t$($p.Value)") }
        }
    }
    $HitRef.Value += $hits; $MissRef.Value += $miss
    return ($res -join $nl)
}

function Invoke-ZipPatch {
    param([string] $ZipPath, $Map, $LangCsvText, [string] $LangArg)

    if (-not (Test-Path $ZipPath)) { Write-Warn2 "Atlandı (yok): $ZipPath"; return $null }

    $zip = [System.IO.Compression.ZipFile]::Open($ZipPath, [System.IO.Compression.ZipArchiveMode]::Update)
    try {
        $utf8 = New-Object System.Text.UTF8Encoding($false)
        $totalHit = 0; $totalMiss = 0; $files = 0
        $keptAll = New-Object System.Collections.Generic.List[string]

        foreach ($entry in @($zip.Entries)) {
            $n = $entry.FullName
            if ($n.EndsWith('/')) { continue }

            if ($n -match '/Text/[^/]+\.utf8$') {
                $stamp = $entry.LastWriteTime
                $s = $entry.Open()
                $ms = New-Object System.IO.MemoryStream
                $s.CopyTo($ms); $s.Close()
                $text = $utf8.GetString($ms.ToArray())
                $ms.Dispose()

                $hit = 0; $miss = 0
                $kept = New-Object System.Collections.Generic.List[string]
                $newText = Convert-TextEntry -Text $text -Map $Map -HitRef ([ref]$hit) -MissRef ([ref]$miss) -KeptRef ([ref]$kept)
                if ($hit -gt 0) {
                    $bytes = $utf8.GetBytes($newText)
                    $entry.Delete()
                    $ne = $zip.CreateEntry($n, [System.IO.Compression.CompressionLevel]::Optimal)
                    $ne.LastWriteTime = $stamp
                    $os = $ne.Open(); $os.Write($bytes, 0, $bytes.Length); $os.Close()
                }
                $totalHit += $hit; $totalMiss += $miss; $files++
                if ($kept) { $keptAll.AddRange($kept) }
            }
            elseif ($n -match '/UI/dblanguage\.csv$') {
                $stamp = $entry.LastWriteTime
                $s = $entry.Open()
                $ms = New-Object System.IO.MemoryStream
                $s.CopyTo($ms); $s.Close()
                $text = $utf8.GetString($ms.ToArray()); $ms.Dispose()

                if ($text -notmatch "(?m)^$([regex]::Escape($Language)),") {
                    $nl = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
                    $row = "$Language,0,`"`"`"$LangArg`"`"`""
                    $text = $text.TrimEnd("`r", "`n") + $nl + $row + $nl
                }
                $bytes = $utf8.GetBytes($text)
                $entry.Delete()
                $ne = $zip.CreateEntry($n, [System.IO.Compression.CompressionLevel]::Optimal)
                $ne.LastWriteTime = $stamp
                $os = $ne.Open(); $os.Write($bytes, 0, $bytes.Length); $os.Close()
                Write-Ok "dil tablosu güncellendi: $n"
            }
        }
        return [PSCustomObject]@{ Files = $files; Hit = $totalHit; Miss = $totalMiss; Kept = $keptAll }
    }
    finally { $zip.Dispose() }
}

# ------------------------------------------------------------------ ana akis
$root = $PSScriptRoot
if (-not $Ceviriler) { $Ceviriler = Join-Path $root 'ceviriler.txt' }
if (-not $LanguageTable) { $LanguageTable = Join-Path $root 'db\UI\dblanguage.csv' }

Write-Host ""
Write-Host "  Empire Earth II — Türkçe Yama" -ForegroundColor White
Write-Host "  --------------------------------------------" -ForegroundColor White

if ($Mode -eq 'Check') {
    $gd = Find-GameDir
    Write-Host ""
    Write-Step "Oyun klasörü: $gd"

    # --- ceviri tablosu
    if (-not $Ceviriler) { $Ceviriler = Join-Path $root 'ceviriler.txt' }
    if (Test-Path $Ceviriler) {
        $n = 0
        foreach ($l in [System.IO.File]::ReadAllLines($Ceviriler, [System.Text.Encoding]::UTF8)) {
            if ($l.Trim().Length -gt 0) { $n++ }
        }
        Write-Ok "Çeviri tablosu: $n metin  ($(Split-Path $Ceviriler -Leaf))"
    } else { Write-Err "Çeviri tablosu bulunamadı: $Ceviriler" }

    # --- arsivler ve yama durumu
    $islendi = 0; $toplam = 0
    foreach ($z in @('zips\db.zip', 'zips_ee2x\EE2X_db.zip')) {
        $p = Join-Path $gd $z
        $toplam++
        if (-not (Test-Path $p)) { Write-Err "Eksik arşiv: $z"; continue }
        $bak = "$p.ee2tr.bak"
        $durum = if (Test-Path $bak) { 'yamalı (yedek mevcut)' } else { 'yedek yok - ya orijinal ya da geri alınmış' }
        Write-Host "    $z  ->  $durum" -ForegroundColor $(if (Test-Path $bak) { 'Green' } else { 'DarkGray' })
        if (Test-Path $bak) { $islendi++ }
    }

    # --- dil ayari
    foreach ($cfg in @('myconfig.cfg', 'myconfig_EE2X.cfg')) {
        $p = Join-Path $gd $cfg
        if (-not (Test-Path $p)) { continue }
        $t = [System.IO.File]::ReadAllText($p)
        $m = [regex]::Match($t, '(?m)^s_Language=(.*)$')
        if ($m.Success -and $m.Groups[1].Value.Trim() -eq 'Turkish') { Write-Ok "$cfg  ->  s_Language=Turkish" }
        elseif ($m.Success) { Write-Warn2 "$cfg  ->  s_Language=$($m.Groups[1].Value.Trim())  (Türkçe değil)" }
        else { Write-Warn2 "$cfg  ->  s_Language yok" }
    }

    # --- dublanguage.csv Turkce karakter girdisi
    foreach ($z in @('zips\db.zip', 'zips_ee2x\EE2X_db.zip')) {
        $p = Join-Path $gd $z
        if (-not (Test-Path $p)) { continue }
        $found = $false
        $za = [System.IO.Compression.ZipFile]::OpenRead($p)
        try {
            foreach ($e in $za.Entries) {
                if ($e.FullName -notlike '*dblanguage.csv') { continue }
                $sr = New-Object System.IO.StreamReader($e.Open(), [System.Text.Encoding]::UTF8)
                $txt = $sr.ReadToEnd(); $sr.Close()
                if ($txt -match 'charSet=Turkish') { $found = $true }
            }
        } finally { $za.Dispose() }
        if ($found) { Write-Ok "$(Split-Path $z -Leaf): Türkçe karakter kümesi tanımlı" }
        else { Write-Warn2 "$(Split-Path $z -Leaf): charSet=Turkish kaydı YOK - yama bozuk olabilir" }
    }

    # --- bdb
    $bdb = Join-Path $gd 'bdb'
    if (Test-Path $bdb) { Write-Ok "bdb/ mevcut (oyun metni derlemiş)" }
    else { Write-Warn2 "bdb/ yok - ilk açılışta derlenecek" }

    Write-Host ""
    if ($islendi -eq $toplam -and $toplam -gt 0) {
        Write-Host "  Durum: YAMA KURULU" -ForegroundColor Green
        Write-Host "  Oyunu başlatabilirsiniz." -ForegroundColor White
    } else {
        Write-Host "  Durum: YAMA KURULMAMIŞ" -ForegroundColor Yellow
        Write-Host "  Kurmak için KURULUM.bat dosyasını çalıştırın." -ForegroundColor White
    }
    exit 0
}

$gd = Find-GameDir
Write-Step "Oyun klasoru: $gd"

$targets = @()
foreach ($z in @('zips\db.zip', 'zips_ee2x\EE2X_db.zip')) {
    $p = Join-Path $gd $z
    if (Test-Path $p) { $targets += $p }
}
if ($targets.Count -eq 0) { throw "Hiçbir db.zip bulunamadı." }

# ---- geri al
if ($Mode -eq 'Undo') {
    $done = $false
    foreach ($t in $targets) {
        $bak = "$t.ee2tr.bak"
        if (Test-Path $bak) {
            Copy-Item $bak $t -Force
            Remove-Item $bak -Force
            Write-Ok "geri alındı: $t"
            $done = $true
        }
        else { Write-Warn2 "yedek yok: $bak" }
    }
    foreach ($cfg in @('myconfig.cfg', 'myconfig_EE2X.cfg')) {
        $p = Join-Path $gd $cfg
        if (Test-Path "$p.ee2tr.bak") {
            Copy-Item "$p.ee2tr.bak" $p -Force; Remove-Item "$p.ee2tr.bak" -Force
            Write-Ok "geri alındı: $cfg"; $done = $true
        }
    }
    $bdb = Join-Path $gd 'bdb'
    if (Test-Path $bdb) { Remove-Item $bdb -Recurse -Force; Write-Ok "derlenmiş bdb silindi (ilk açılışta yeniden derlenecek)" }
    if (-not $done) { Write-Warn2 "Geri alınacak yedek bulunamadı." }
    Write-Host "`n  Tamam.`n" -ForegroundColor Green
    exit 0
}

# ---- kur
$Map = Read-Ceviriler $Ceviriler
if ($Kodlama -eq 'Ascii') {
    foreach ($k in @($Map.Keys)) { $Map[$k] = Convert-ToAscii $Map[$k] }
    Write-Ok "Karakter kodu: ASCII (Turkce harfler duz harflere indirgendi)"
}
$langArg = if ($Kodlama -eq 'Ascii') { '' } else { 'charSet=Turkish' }

# 1) yedekle
Write-Step "Yedek alınıyor..."
foreach ($t in $targets) {
    $bak = "$t.ee2tr.bak"
    if (-not (Test-Path $bak)) { Copy-Item $t $bak -Force; Write-Ok "yedek: $(Split-Path $t -Leaf).ee2tr.bak" }
    else { Write-Ok "yedek zaten var: $(Split-Path $t -Leaf).ee2tr.bak" }
}
foreach ($cfg in @('myconfig.cfg', 'myconfig_EE2X.cfg')) {
    $p = Join-Path $gd $cfg
    if ((Test-Path $p) -and -not (Test-Path "$p.ee2tr.bak")) { Copy-Item $p "$p.ee2tr.bak" -Force }
}

# 2) yaz
$grand = [PSCustomObject]@{ Files = 0; Hit = 0; Miss = 0 }
$keptAll = New-Object System.Collections.Generic.List[string]
foreach ($t in $targets) {
    Write-Step "İşleniyor: $(Split-Path $t -Leaf)"
    $r = Invoke-ZipPatch -ZipPath $t -Map $Map -LangCsvText $null -LangArg $langArg
    if ($r) {
        Write-Ok "$($r.Files) metin dosyası, $($r.Hit) metin çevrildi, $($r.Miss) metin Türkçe değil"
        $grand.Files += $r.Files; $grand.Hit += $r.Hit; $grand.Miss += $r.Miss
        $keptAll.AddRange($r.Kept)
    }
}

# 3) derlenmis veritabanini temizle -> oyun yeniden derler
$bdb = Join-Path $gd 'bdb'
if (Test-Path $bdb) { Remove-Item $bdb -Recurse -Force; Write-Ok "bdb/ silindi (oyun yeniden derleyecek)" }

# 4) dili ayarla
Write-Step "Dil ayarlanıyor..."
foreach ($cfg in @('myconfig.cfg', 'myconfig_EE2X.cfg')) {
    $p = Join-Path $gd $cfg
    if (-not (Test-Path $p)) { continue }
    $txt = [System.IO.File]::ReadAllText($p)
    if ($txt -match '(?m)^s_Language=.*$') { $txt = [regex]::Replace($txt, '(?m)^s_Language=.*$', "s_Language=$Language") }
    else { $txt = "s_Language=$Language`r`n" + $txt }
    Write-Utf8NoBom $p $txt
    Write-Ok "$cfg -> s_Language=$Language"
}

# 5) cevrilmemisleri raporla
$rep = Join-Path $root 'CEVIRILMEMIS.txt'
if ($keptAll.Count -gt 0) {
    $uniq = $keptAll | Sort-Object -Unique
    Write-Utf8NoBom $rep (($uniq -join "`r`n") + "`r`n")
    Write-Warn2 "$($uniq.Count) metin hâlâ İngilizce -> CEVIRILMEMIS.txt"
}

Write-Host ""
Write-Host "  --------------------------------------------" -ForegroundColor White
Write-Host "  Tamamlandı." -ForegroundColor Green
Write-Host ("  {0} dosya, {1} metin çevrildi, {2} metin bekliyor." -f $grand.Files, $grand.Hit, $grand.Miss) -ForegroundColor White
Write-Host "  İlk açılışta oyun metni yeniden derleyecek (birkaç saniye sürebilir)." -ForegroundColor Yellow
Write-Host "  Geri almak için: GERI-AL.bat`n" -ForegroundColor Yellow