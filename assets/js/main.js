document.addEventListener('DOMContentLoaded', () => {
  const year = new Date().getFullYear();
  const footer = document.querySelector('.footer p');
  if (footer) footer.textContent = `© ${year} Zsazsa. Semua konten dibuat dengan bahasa Indonesia.`;
});
