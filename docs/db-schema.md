# Database schema rekomendasi (PostgreSQL)

Direkomendasikan menggunakan PostgreSQL untuk stabilitas transaksi dan fitur relasional.

Ringkasan tabel utama:

- `users` — data pelanggan dan admin
- `products` — katalog produk
- `orders` — header pesanan
- `order_items` — daftar item tiap pesanan
- `transactions` — bukti & status pembayaran
- `technicians` — data teknisi service
- `service_requests` — request servis/booking
- `referrals` — data referral/affiliate

File SQL contoh: `db/schema_postgres.sql`
