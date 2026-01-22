# 📝 Görev Listesi (Moleküler Tasklar)

> Her görev atomik, tek seferde tamamlanabilir ve doğrulanabilir olmalıdır.

---

## Mevcut Sprint

### Öncelik: P0 (Kritik)

- [ ] **TASK-001**: [Görev açıklaması]
  - Dosya: `path/to/file`
  - Doğrulama: `verify.sh` başarılı

- [ ] **TASK-002**: [Görev açıklaması]
  - Dosya: `path/to/file`
  - Doğrulama: Test geçmeli

### Öncelik: P1 (Yüksek)

- [ ] **TASK-003**: [Görev açıklaması]
  - Dosya: `path/to/file`
  - Bağımlılık: TASK-001

### Öncelik: P2 (Normal)

- [ ] **TASK-004**: [Görev açıklaması]
  - Notlar: Opsiyonel detaylar

---

## Tamamlanan Görevler

### Sprint 1
*Henüz tamamlanan görev yok*

---

## Görev Formatı

```markdown
- [ ] **TASK-XXX**: Kısa, aksiyon odaklı açıklama
  - Dosya: Değiştirilecek ana dosya
  - Doğrulama: Nasıl doğrulanacak
  - Bağımlılık: Önce tamamlanması gereken görev (varsa)
  - Notlar: Ek bilgi (isteğe bağlı)
```

---

## Kurallar

1. **Atomik**: Her görev tek seferde tamamlanabilir
2. **Bağımsız**: Mümkün olduğunca bağımsız olmalı
3. **Doğrulanabilir**: verify.sh ile kontrol edilebilir
4. **Açık**: Görev açıklaması belirsizlik içermemeli
5. **Sıralı**: Bağımlılıklar açıkça belirtilmeli

---

## Durum İşaretleri

- `[ ]` Beklemede
- `[x]` Tamamlandı
- `[!]` Bloke edildi
- `[~]` Devam ediyor

---

*Ajanlar bu dosyadan sırayla görev alır ve tamamlandıkça işaretler.*
