const menus = [...document.querySelectorAll('.header-actions details')];

document.addEventListener('click', event => {
  for (const menu of menus) {
    if (menu.open && !menu.contains(event.target)) menu.open = false;
  }
});

document.addEventListener('keydown', event => {
  if (event.key !== 'Escape') return;
  for (const menu of menus) {
    if (!menu.open) continue;
    menu.open = false;
    menu.querySelector('summary').focus();
  }
});

for (const menu of menus) {
  menu.addEventListener('toggle', () => {
    if (!menu.open) return;
    for (const other of menus) {
      if (other !== menu) other.open = false;
    }
  });
}
