# Empire Earth II â€” TÃ¼rkÃ§e Yama

Empire Earth II'nin (Steam, Gold Edition) arayÃ¼zÃ¼nÃ¼ ve oyun metinlerini
TÃ¼rkÃ§eye Ã§eviren yamadÄ±r. `EE2.exe` ve `EE2X.exe` (The Art of Supremacy)
ikisini de kapsar.

---

## Kurulum

1. `KURULUM.bat` dosyasÄ±na **Ã§ift tÄ±klayÄ±n**.
2. Oyun **kapalÄ±yken** Ã§alÄ±ÅŸtÄ±rÄ±n.
3. Oyunu baÅŸlatÄ±n. Ä°lk aÃ§Ä±lÄ±ÅŸta oyun metin dosyalarÄ±nÄ± yeniden derler;
   bu birkaÃ§ saniye sÃ¼rebilir, normaldir.

Kurulum sÄ±rasÄ±nda oyunun kendi dosyalarÄ± (`.ee2tr.bak` uzantÄ±sÄ±yla)
yedeklenir. **HiÃ§bir dosya silinmez**, oyun klasÃ¶rÃ¼ne yalnÄ±zca geri alma
iÃ§in yedekler eklenir.

Oyun klasÃ¶rÃ¼nÃ¼ bulmak iÃ§in yama, Steam kayÄ±tlarÄ±nÄ± ve `C/D/E/F` sÃ¼rÃ¼cÃ¼lerindeki
`SteamLibrary` klasÃ¶rlerini tarar. Bulamazsa `Ee2Yama.ps1 -GameDir "<yol>"`
ÅŸeklinde elle verebilirsiniz.

## Yama kurulu mu?

`KONTROL.bat` dosyasÄ±nÄ± Ã§alÄ±ÅŸtÄ±rÄ±n. ÅunlarÄ± raporlar:

- Ã§eviri tablosundaki metin sayÄ±sÄ±
- arÅŸivlerin yamalÄ± olup olmadÄ±ÄŸÄ±
- `myconfig.cfg` iÃ§indeki dil ayarÄ±
- TÃ¼rkÃ§e karakter kÃ¼mesinin tanÄ±mlÄ± olup olmadÄ±ÄŸÄ±
- `bdb/` Ã¶nbelleÄŸinin durumu

## Geri alma

`GERI-AL.bat` dosyasÄ±na Ã§ift tÄ±klayÄ±n. Oyun orijinal Ä°ngilizce haline dÃ¶ner.

---

## NasÄ±l Ã§alÄ±ÅŸÄ±r

Empire Earth II bÃ¼tÃ¼n metinlerini exe iÃ§inde deÄŸil, oyun klasÃ¶rÃ¼ndeki
`zips/db.zip` ve `zips_ee2x/EE2X_db.zip` arÅŸivlerindeki
`db/Text/dbtext_*.utf8` dosyalarÄ±nda tutar. Oyun ilk aÃ§Ä±lÄ±ÅŸta bu dosyalarÄ±
okuyup `bdb/` klasÃ¶rÃ¼ne derler.

Yama:

1. bu dosyalarÄ±n **anahtar/deÄŸer** satÄ±rlarÄ±nÄ± TÃ¼rkÃ§e deÄŸerlerle deÄŸiÅŸtirir,
2. arÅŸivlerdeki `dblanguage.csv` dosyasÄ±na `Turkish / charSet=Turkish`
   girdisini ekler,
3. `bdb/` klasÃ¶rÃ¼nÃ¼ siler (yeniden derlenmesi iÃ§in),
4. `myconfig.cfg` ve `myconfig_EE2X.cfg` iÃ§indeki `s_Language` ayarÄ±nÄ±
   `Turkish` yapar.

**Exe'ye, kod dosyalarÄ±na, gÃ¶rsellere veya seslere dokunulmaz.**
DeÄŸiÅŸen tek ÅŸey oyunun kendi metin veritabanÄ±dÄ±r.

TÃ¼rkÃ§e karakterler (Ä±, Ä°, ÅŸ, ÄŸ, Ã§, Ã¶, Ã¼) `charSet=Turkish` girdisi
sayesinde Windows'un ISO-8859-9 karakter setiyle doÄŸru Ã§izilir.

---

## Ne kadar Ã§evrildi

| Durum | Metin sayÄ±sÄ± |
|---|---|
| Toplam (EE2 + Art of Supremacy) | 13.933 |
| TÃ¼rkÃ§eye Ã§evrilmiÅŸ | `SURUM.txt` iÃ§indeki sayÄ±ya bakÄ±n |
| Kalanlar | kurulumdan sonra `CEVIRILMEMIS.txt` dosyasÄ±na yazÄ±lÄ±r |

HenÃ¼z Ã§evrilmemiÅŸ metinler orijinal Ä°ngilizcesiyle kalÄ±r; **oyun bozulmaz.**
Ã‡eviri aÅŸamalÄ± ilerliyor: Ã¶nce en Ã§ok gÃ¶rÃ¼nen arayÃ¼z, ardÄ±ndan senaryo
diyaloglarÄ± ve film altyazÄ±larÄ±.

---

## Bilinen sÄ±nÄ±rlar

- **Steam "DosyalarÄ± DoÄŸrula"** yaparsanÄ±z `zips/db.zip` orijinaline dÃ¶ner.
  Yama bozulmaz ama etkisini kaybeder; tekrar `KURULUM.bat` Ã§alÄ±ÅŸtÄ±rÄ±n.
- Steam gÃ¼ncellemesinden sonra da aynÄ± ÅŸekilde yamayÄ± yeniden kurun.
- **Hile kodlarÄ±** (`icheat`, `win`, `taxes` vb.) kasÄ±tlÄ± olarak Ä°ngilizce
  bÄ±rakÄ±lmÄ±ÅŸtÄ±r; oyuncu bunlarÄ± harf harf yazar.
- **Senaryo diyaloglarÄ± ve film altyazÄ±larÄ±nÄ±n bir kÄ±smÄ±** henÃ¼z Ä°ngilizce
  kalabilir. Bu bir eksik deÄŸil, bilinen bir aÅŸamadÄ±r.
- Yama tek oyunculu kullanÄ±m iÃ§indir; Ã§evrim iÃ§i sunucularÄ±, hile korumasÄ±
  veya anti-cheat sistemlerini etkilemez ve hedeflemez.

---

## Dosyalar

| Dosya | AÃ§Ä±klama |
|---|---|
| `KURULUM.bat` | YamayÄ± kurar |
| `GERI-AL.bat` | YamayÄ± geri alÄ±r |
| `KONTROL.bat` | Kurulumun durumunu raporlar |
| `ASCII-KARS-MODU.bat` | TÃ¼rkÃ§e harfler gÃ¶rÃ¼nmÃ¼yorsa ASCII kipini kurar |
| `Ee2Yama.ps1` | Kurulum / geri alma / kontrol motoru |
| `ceviriler.txt` | TÃ¼rkÃ§e Ã§eviriler (`anahtar<TAB>metin`, UTF-8) |
| `SURUM.txt` | SÃ¼rÃ¼m, kapsam ve SHA-256 Ã¶zetleri |
| `SHA256SUMS.txt` | Dosya bÃ¼tÃ¼nlÃ¼k Ã¶zetleri |
| `CEVIRILMEMIS.txt` | Kurulumdan sonra Ã¼retilir: kalan Ä°ngilizce metinler |

---

## NasÄ±l Ã§evrildi

TÃ¼m metinler **elle, doÄŸrudan TÃ¼rkÃ§eden** Ã§evrildi. HiÃ§bir harici Ã§eviri
servisi (DeepL, Google Translate, Ã§evrim iÃ§i araÃ§ vb.) kullanÄ±lmamÄ±ÅŸtÄ±r.

Ã‡eviriler oyunun kendi terminolojisine gÃ¶re tutarlÄ± bir sÃ¶zlÃ¼kle yapÄ±ldÄ±:

| Ä°ngilizce | TÃ¼rkÃ§e |
|---|---|
| Epoch | Ã‡aÄŸ |
| Power (unit special power) | GÃ¼Ã§ |
| Citizen | VatandaÅŸ |
| Crown | TaÃ§ |
| Heavy Infantry | AÄŸÄ±r Piyade |
| Build / Repair | Ä°nÅŸa / Onar |
| Tribute | Vergi |
| Ally / Alliance | MÃ¼ttefik / Ä°ttifak |
| Wonder | Harika |
| Territory | BÃ¶lge |

DeÄŸiÅŸken yer tutucular (`%PLAYER%`, `%TIME%`), kaÃ§Ä±ÅŸ dizileri (`\n`, `\"`, `\\`)
ve stil etiketleri (`<color blue>`, `<indent>`, `<smallCaps>`) kaynakla **birebir**
korunur. Ã‡eviri sÄ±rasÄ±nda biri kaybolursa veya sayÄ±sÄ± deÄŸiÅŸirse derleme
hatasÄ± verir ve yama Ã¼retilmez.