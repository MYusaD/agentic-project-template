# 📜 AGENTS.md - Ajan Anayasası

> Bu döküman, bu projede çalışan tüm AI ajanları için bağlayıcı kurallardır.

## 🎯 Temel Prensipler

### 1. Tek Görev Kuralı
- Ajan her seferinde **SADECE BİR** görev üzerinde çalışır
- Görev `docs/TASKS.md` dosyasından seçilir
- Birden fazla görev tek seferde yapılamaz

### 2. Doğrulama Zorunlu
- Her değişiklikten sonra `scripts/verify.sh` çalıştırılmalıdır
- Doğrulama başarısız olursa, değişiklik tamamlanmamış sayılır
- Commit öncesi doğrulama ZORUNLUDUR

### 3. Loglama
- Her eylem `logs/progress.md` dosyasına kaydedilir
- Log formatı: `[TARİH] [GÖREV] [DURUM] [NOTLAR]`
- Sessiz değişiklik yapılamaz

### 4. Güvenlik Kuralları
- `--dangerously-skip-permissions` kullanılamaz
- Dış API'lere izinsiz istek atılamaz
- Dosya silme işlemi onay gerektirir
- Sistem dosyalarına erişim yasaktır

### 5. Git Kuralları (GitFlow)
- **Feature Branch**: Her görev için yeni branch aç: `feature/task-id-kisa-aciklama`
- **Main Branch**: Sadece çalışan ve test edilmiş kod merge edilir.
- **Commit Mesajları**: Conventional Commits formatı zorunludur: `feat:`, `fix:`, `docs:`.

---

## 🔄 Çalışma Döngüsü

```
1. OKUMA
   ├── docs/AGENTS.md (bu dosya)
   ├── docs/PRD.md
   ├── docs/TASKS.md
   └── logs/progress.md

2. SEÇİM
   └── TASKS.md'den tamamlanmamış ilk görevi seç

3. UYGULAMA
   ├── Görevi uygula
   ├── verify.sh çalıştır
   └── Başarısızsa düzelt ve tekrar dene

4. KAYIT
   ├── progress.md güncelle
   ├── TASKS.md'de görevi tamamlandı işaretle
   └── Gerekirse FEATURES.md güncelle

5. DURDUR
   └── Tek görev tamamlandı, dur
```

---

## 📋 Log Formatı

```markdown
## [2024-01-15 14:30]

### Görev
- ID: TASK-001
- Açıklama: Login sayfası oluştur

### Yapılanlar
- src/pages/login.tsx oluşturuldu
- src/components/LoginForm.tsx oluşturuldu

### Doğrulama
- ✅ verify.sh başarılı
- ✅ Testler geçti

### Durum
TAMAMLANDI
```

---

## ⚠️ Yasaklar

1. **Paralel görev yok**: Tek seferde tek görev
2. **Sessiz değişiklik yok**: Her şey loglanmalı
3. **Doğrulamasız commit yok**: verify.sh zorunlu
4. **Yetkisiz erişim yok**: Sadece proje dosyaları
5. **Skip permissions yok**: Güvenlik açığı

---

## 🏁 Tamamlanma Sinyali

Ajan tüm görevleri tamamladığında çıktısında şu token bulunmalı:

```
<promise>COMPLETE</promise>
```

Bu token, loop.sh tarafından algılanır ve döngü sonlandırılır.

---

## 📖 Referanslar

- PRD: `docs/PRD.md`
- Görevler: `docs/TASKS.md`
- Özellikler: `docs/FEATURES.md`
- İlerleme: `logs/progress.md`
- Prompt: `docs/PROMPT.md`
