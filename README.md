# Zsazsa Blog

![banner](./.github/images/banner.svg)

Portal digital modern berbahasa Indonesia untuk blog, firmware, produk, affiliate, dan dashboard admin.

[![Website](https://img.shields.io/badge/site-online-green)](https://zsazsa.example) [![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

## Ikon
<p>
	<img alt="icon" src="./.github/images/icon.svg" width="64" height="64" />
</p>

## Open Graph / Social Preview

GitHub uses the repository social preview image for link previews. I added a PNG social preview at `/.github/images/banner.png` which is suitable for Open Graph and Twitter Cards.

If you host the site, include these meta tags in your HTML head (example):

```html
<meta property="og:title" content="Zsazsa — Portal Digital Indonesia" />
<meta property="og:description" content="Platform lengkap untuk blog, firmware, toko, affiliate, dan dashboard admin — semua dalam bahasa Indonesia." />
<meta property="og:type" content="website" />
<meta property="og:url" content="https://zsazsa.example/" />
<meta property="og:image" content="https://raw.githubusercontent.com/Zsazsa-hub/Zsazsa-Blog/main/.github/images/banner.png" />
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:image" content="https://raw.githubusercontent.com/Zsazsa-hub/Zsazsa-Blog/main/.github/images/banner.png" />
```

You can also set the repository Social Preview image in GitHub Settings → Repository settings → Social preview (choose `/.github/images/banner.png`). This controls how your repo appears when shared on social platforms.

## Fitur utama
- Blog SEO lengkap
- Firmware dan sistem download
- Produk, toko, stok, dan marketplace
- Affiliate, komisi, dan tracking
- Dashboard admin modern
- Integrasi WhatsApp, Telegram, QRIS, COD, dan pembayaran digital

## Jalankan lokal
```bash
npm install
npm run dev
```

Atau dengan Docker:
```bash
docker compose up --build
```

Akses di http://localhost:3000
