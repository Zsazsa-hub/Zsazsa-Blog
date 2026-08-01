document.addEventListener('DOMContentLoaded', () => {
  const year = new Date().getFullYear();
  const footer = document.querySelector('.footer p');
  const themeToggle = document.getElementById('theme-toggle');

  if (footer) {
    footer.textContent = `© ${year} Zsazsa. Semua konten dibuat dengan bahasa Indonesia.`;
  }

  const applyTheme = (theme) => {
    const isDark = theme === 'dark';
    document.documentElement.setAttribute('data-theme', isDark ? 'dark' : 'light');
    document.documentElement.style.colorScheme = isDark ? 'dark' : 'light';
    if (themeToggle) {
      themeToggle.textContent = isDark ? '☀️ Terang' : '🌙 Gelap';
    }
  };

  const savedTheme = localStorage.getItem('zsazsa-theme') || 'dark';
  applyTheme(savedTheme);

  if (themeToggle) {
    themeToggle.addEventListener('click', () => {
      const nextTheme = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
      localStorage.setItem('zsazsa-theme', nextTheme);
      applyTheme(nextTheme);
    });
  }
});
